# ============================================================
# environments/prod/main.tf
# ============================================================

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}

# ─────────────────────────────────────────────────────────────
# 0. Parameter Store se secrets uthao
#    AWS Console → Systems Manager → Parameter Store mein
#    yeh paths pehle banao
# ─────────────────────────────────────────────────────────────
data "aws_ssm_parameter" "db_password" {
  name            = "${var.ssm_path}/db_password"
  with_decryption = true
}

data "aws_ssm_parameter" "db_username" {
  name            = "${var.ssm_path}/db_username"
  with_decryption = true
}

data "aws_ssm_parameter" "jwt_secret" {
  name            = "${var.ssm_path}/jwt_secret"
  with_decryption = true
}

data "aws_ssm_parameter" "smtp_user" {
  name            = "${var.ssm_path}/smtp_user"
  with_decryption = true
}

data "aws_ssm_parameter" "smtp_password" {
  name            = "${var.ssm_path}/smtp_password"
  with_decryption = true
}

data "aws_ssm_parameter" "groq_api_key" {
  name            = "${var.ssm_path}/groq_api_key"
  with_decryption = true
}

data "aws_ssm_parameter" "cf_origin_secret" {
  name            = "${var.ssm_path}/cf_origin_secret"
  with_decryption = true
}

# ─────────────────────────────────────────────────────────────
# 1. VPC — Network Foundation
# ─────────────────────────────────────────────────────────────
module "vpc" {
  source = "../modules/vpc"

  project    = var.project
  vpc_cidr   = var.vpc_cidr

  availability_zones        = var.availability_zones
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs
  single_nat_gateway        = var.single_nat_gateway

  common_tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# 2. Security Groups
# ─────────────────────────────────────────────────────────────
module "security_groups" {
  source = "../modules/security-groups"

  project                 = var.project
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = var.vpc_cidr
  bastion_allowed_cidrs   = var.bastion_allowed_cidrs
  frontend_port           = var.frontend_port
  backend_port            = var.backend_port
  allow_bastion_db_access = var.allow_bastion_db_access

  common_tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# 3. Bastion Host
# ─────────────────────────────────────────────────────────────
module "bastion" {
  source = "../modules/bastion"

  project          = var.project
  public_subnet_id = module.vpc.public_subnet_ids[0]
  bastion_sg_id    = module.security_groups.bastion_sg_id
  key_pair_name    = var.key_pair_name
  instance_type    = var.bastion_instance_type

  common_tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# 4. ACM Certificate — COMMENT HAI (domain chahiye)
# ─────────────────────────────────────────────────────────────
# resource "aws_acm_certificate" "main" {
#   provider                  = aws.us_east_1
#   domain_name               = var.domain_name
#   subject_alternative_names = ["*.${var.domain_name}"]
#   validation_method         = "DNS"
#   lifecycle { create_before_destroy = true }
#   tags = merge(local.common_tags, { Name = "${var.project}-cert" })
# }

# ─────────────────────────────────────────────────────────────
# 5. Route53 — COMMENT HAI (domain chahiye)
# ─────────────────────────────────────────────────────────────
# module "route53" { ... }
# resource "aws_acm_certificate_validation" "main" { ... }

# ─────────────────────────────────────────────────────────────
# 6. Frontend ALB — Internet-facing
# ─────────────────────────────────────────────────────────────
module "frontend_alb" {
  source = "../modules/alb"

  project    = var.project
  tier       = "frontend"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id  = module.security_groups.frontend_alb_sg_id
  internal   = false

  target_port       = var.frontend_port
  health_check_path = var.frontend_health_check_path
  certificate_arn   = ""
  enable_stickiness = var.frontend_enable_stickiness

  common_tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# 7. Backend ALB — Internal only
# ─────────────────────────────────────────────────────────────
module "backend_alb" {
  source = "../modules/alb"

  project    = var.project
  tier       = "backend"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_app_subnet_ids
  alb_sg_id  = module.security_groups.backend_alb_sg_id
  internal   = true

  target_port       = var.backend_port
  health_check_path = var.backend_health_check_path
  certificate_arn   = ""

  common_tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# 8. Frontend ASG
# ─────────────────────────────────────────────────────────────
module "frontend_asg" {
  source = "../modules/ec2-asg"

  project            = var.project
  tier               = "frontend"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_app_subnet_ids
  ec2_sg_id          = module.security_groups.frontend_ec2_sg_id
  target_group_arn   = module.frontend_alb.target_group_arn
  key_pair_name      = var.key_pair_name

  ami_id        = var.frontend_ami_id
  instance_type = var.frontend_instance_type

  min_size         = var.frontend_min_size
  max_size         = var.frontend_max_size
  desired_capacity = var.frontend_desired_capacity

  user_data_base64 = base64encode(templatefile("${path.module}/startup-scripts/frontend.sh", {
    backend_alb_dns = module.backend_alb.alb_dns_name
  }))

  common_tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# 9. Backend ASG
# ─────────────────────────────────────────────────────────────
module "backend_asg" {
  source = "../modules/ec2-asg"

  project            = var.project
  tier               = "backend"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_app_subnet_ids
  ec2_sg_id          = module.security_groups.backend_ec2_sg_id
  target_group_arn   = module.backend_alb.target_group_arn
  key_pair_name      = var.key_pair_name

  ami_id        = var.backend_ami_id
  instance_type = var.backend_instance_type

  min_size         = var.backend_min_size
  max_size         = var.backend_max_size
  desired_capacity = var.backend_desired_capacity

  # Secrets Parameter Store se aa rahe hain — koi bhi value
  # plaintext mein nahi hai
  user_data_base64 = base64encode(templatefile("${path.module}/startup-scripts/backend.sh", {
    db_host     = module.rds.db_address
    db_name     = var.db_name
    db_user     = data.aws_ssm_parameter.db_username.value
    db_password = data.aws_ssm_parameter.db_password.value
    jwt_secret  = data.aws_ssm_parameter.jwt_secret.value
    smtp_user   = data.aws_ssm_parameter.smtp_user.value
    smtp_pass   = data.aws_ssm_parameter.smtp_password.value
    groq_key    = data.aws_ssm_parameter.groq_api_key.value
  }))

  common_tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# 10. RDS MySQL
# ─────────────────────────────────────────────────────────────
module "rds" {
  source = "../modules/rds"

  project                 = var.project
  private_data_subnet_ids = module.vpc.private_data_subnet_ids
  rds_sg_id               = module.security_groups.rds_sg_id

  db_name     = var.db_name
  db_username = data.aws_ssm_parameter.db_username.value
  db_password = data.aws_ssm_parameter.db_password.value

  instance_class              = var.rds_instance_class
  allocated_storage           = var.rds_allocated_storage
  max_allocated_storage       = var.rds_max_allocated_storage
  multi_az                    = var.rds_multi_az
  backup_retention_days       = var.rds_backup_retention_days
  skip_final_snapshot         = false
  deletion_protection         = true
  enable_performance_insights = true

  alarm_sns_arns = var.alarm_sns_arns
  common_tags    = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# 11. CloudFront
# ─────────────────────────────────────────────────────────────
module "cloudfront" {
  source = "../modules/cloudfront"

  project               = var.project
  frontend_alb_dns_name = module.frontend_alb.alb_dns_name
  backend_alb_dns_name  = module.backend_alb.alb_dns_name
  domain_aliases        = []
  acm_certificate_arn   = ""
  origin_secret_header  = data.aws_ssm_parameter.cf_origin_secret.value
  price_class           = var.cf_price_class

  common_tags = local.common_tags
}

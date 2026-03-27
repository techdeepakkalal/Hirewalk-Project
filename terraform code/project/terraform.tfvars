# ================================================================
#  terraform.tfvars — ONLY THIS FILE NEEDS TO BE CHANGED
#  No secrets are stored here — everything is in Parameter Store
# ================================================================

# ── Project ─────────────────────────────────────────────────
project     = "hirewalk"
environment = "prod"
owner       = "HireWalk Team"
aws_region  = "us-west-2"

# ── Parameter Store base path ────────────────────────────────
# Create parameters in AWS Console using this path
ssm_path = "/hirewalk/prod"

# ── Security ─────────────────────────────────────────────────
bastion_allowed_cidrs   = ["106.216.207.59/32"]
allow_bastion_db_access = false
key_pair_name           = "hirewalk-keypair"

# ── Domain ───────────────────────────────────────────────────
domain_name         = "hirewalk.com"
create_route53_zone = false

# ── Networking ───────────────────────────────────────────────
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]

public_subnet_cidrs       = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
private_data_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24"]

single_nat_gateway = false

# ── Frontend ─────────────────────────────────────────────────
frontend_port              = 80
frontend_health_check_path = "/health"
frontend_enable_stickiness = false
frontend_ami_id            = "ami-03caad32a158f72db"
frontend_instance_type     = "t3.small"
frontend_min_size          = 1
frontend_max_size          = 2
frontend_desired_capacity  = 1

# ── Backend ──────────────────────────────────────────────────
backend_port              = 5000
backend_health_check_path = "/api/health"
backend_ami_id            = "ami-03caad32a158f72db"
backend_instance_type     = "t3.small"
backend_min_size          = 1
backend_max_size          = 2
backend_desired_capacity  = 1

# ── RDS ──────────────────────────────────────────────────────
db_name                   = "walkin_platform"
rds_instance_class        = "db.t3.medium"
rds_allocated_storage     = 20
rds_max_allocated_storage = 100
rds_multi_az              = true
rds_backup_retention_days = 7

# ── CloudFront ───────────────────────────────────────────────
cf_price_class = "PriceClass_100"

# ── Monitoring ───────────────────────────────────────────────
alarm_sns_arns        = []
bastion_instance_type = "t3.micro"

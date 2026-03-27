# ============================================================
# environments/prod/variables.tf
# ============================================================

# ── Project ─────────────────────────────────────────────────
variable "project" {
  description = "Project name — used as prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (prod, staging, dev)"
  type        = string
}

variable "owner" {
  description = "Team/person owning this infra (for tags)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# ── Networking ───────────────────────────────────────────────
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "availability_zones" {
  description = "List of AZs"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnets — Bastion + ALBs"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "Private app subnets — Frontend + Backend EC2s"
  type        = list(string)
}

variable "private_data_subnet_cidrs" {
  description = "Private data subnets — RDS"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "true = sasta | false = HA (one per AZ)"
  type        = bool
}

# ── Security ─────────────────────────────────────────────────
variable "bastion_allowed_cidrs" {
  description = "Office/home IPs allowed to SSH into Bastion"
  type        = list(string)
}

variable "allow_bastion_db_access" {
  description = "Allow Bastion to connect to RDS (debug only)"
  type        = bool
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
}

# ── Domain ───────────────────────────────────────────────────
variable "domain_name" {
  description = "Your domain (e.g. hirewalk.com)"
  type        = string
}

variable "create_route53_zone" {
  description = "true = naya zone banao | false = existing use karo"
  type        = bool
}

# ── Frontend ─────────────────────────────────────────────────
variable "frontend_port" {
  description = "Frontend app port (Nginx = 80)"
  type        = number
}

variable "frontend_health_check_path" {
  type = string
}

variable "frontend_enable_stickiness" {
  type = bool
}

variable "frontend_ami_id" {
  description = "AMI ID for frontend EC2"
  type        = string
}

variable "frontend_instance_type" {
  type = string
}

variable "frontend_min_size" {
  type = number
}

variable "frontend_max_size" {
  type = number
}

variable "frontend_desired_capacity" {
  type = number
}

# ── Backend ──────────────────────────────────────────────────
variable "backend_port" {
  description = "Backend app port (Flask = 5000)"
  type        = number
}

variable "backend_health_check_path" {
  type = string
}

variable "backend_ami_id" {
  description = "AMI ID for backend EC2"
  type        = string
}

variable "backend_instance_type" {
  type = string
}

variable "backend_min_size" {
  type = number
}

variable "backend_max_size" {
  type = number
}

variable "backend_desired_capacity" {
  type = number
}

# ── RDS ──────────────────────────────────────────────────────
variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_allocated_storage" {
  type = number
}

variable "rds_max_allocated_storage" {
  type = number
}

variable "rds_multi_az" {
  type = bool
}

variable "rds_backup_retention_days" {
  type = number
}

# ── CloudFront ───────────────────────────────────────────────
variable "cf_price_class" {
  type = string
}

# ── Monitoring ───────────────────────────────────────────────
variable "alarm_sns_arns" {
  description = "SNS topic ARNs for CloudWatch alarms"
  type        = list(string)
}

variable "bastion_instance_type" {
  type = string
}

# ── Parameter Store paths ────────────────────────────────────
# Yeh variables terraform ko batate hain ki Parameter Store
# mein kahan se secrets uthane hain
variable "ssm_path" {
  description = "Parameter Store base path — e.g. /hirewalk/prod"
  type        = string
}

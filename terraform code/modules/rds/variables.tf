# modules/rds/variables.tf

variable "project" { type = string }

variable "private_data_subnet_ids" {
  description = "Private data subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security group ID for RDS"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Master DB username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master DB password"
  type        = string
  sensitive   = true
}

variable "engine_version" {
  type    = string
  default = "8.0"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "max_allocated_storage" {
  description = "Auto-scaling max storage (GB)"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable Multi-AZ for HA (recommended for prod)"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "skip_final_snapshot" {
  description = "Set true only for dev/staging"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Prevent accidental deletion. Set false only to destroy."
  type        = bool
  default     = true
}

variable "enable_performance_insights" {
  type    = bool
  default = true
}

variable "kms_key_arn" {
  description = "KMS key for encryption. Leave null to use AWS managed key."
  type        = string
  default     = null
}

variable "alarm_sns_arns" {
  description = "SNS topic ARNs for CloudWatch alarms"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

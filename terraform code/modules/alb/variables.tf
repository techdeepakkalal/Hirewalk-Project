# modules/alb/variables.tf

variable "project" { type = string }

variable "tier" {
  description = "frontend or backend (used in resource names)"
  type        = string
  # Values: "frontend" or "backend"
}

variable "vpc_id" { type = string }

variable "subnet_ids" {
  description = "Public subnets for frontend ALB; Private app subnets for backend ALB"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group for this ALB"
  type        = string
}

variable "internal" {
  description = "false = internet-facing (frontend), true = internal (backend)"
  type        = bool
  default     = false
}

variable "target_port" {
  description = "Port your app listens on"
  type        = number
}

variable "health_check_path" {
  description = "Health check endpoint"
  type        = string
  default     = "/health"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS. Leave empty for HTTP only."
  type        = string
  default     = ""
}

variable "enable_stickiness" {
  description = "Enable sticky sessions (needed for stateful frontends)"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  type    = bool
  default = true
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs (leave empty to disable)"
  type        = string
  default     = ""
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

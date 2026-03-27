# modules/security-groups/variables.tf

variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "bastion_allowed_cidrs" {
  description = "CIDRs allowed to SSH into Bastion. Use your office/home IP."
  type        = list(string)
  # NEVER use ["0.0.0.0/0"] for bastion in prod!
}

variable "frontend_port" {
  description = "Port the frontend app listens on (e.g. 3000 for React/Next.js)"
  type        = number
  default     = 3000
}

variable "backend_port" {
  description = "Port the backend app listens on (e.g. 8080 for Node/Django)"
  type        = number
  default     = 8080
}

variable "allow_bastion_db_access" {
  description = "Allow Bastion to connect to RDS directly (for debugging)"
  type        = bool
  default     = false
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

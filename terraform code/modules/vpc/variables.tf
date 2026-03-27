# modules/vpc/variables.tf

variable "project" {
  description = "Project name — used as prefix for all resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs (at least 2 for HA)"
  type        = list(string)
  # Example: ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (Bastion + ALB)"
  type        = list(string)
  # Example: ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private app subnets (Frontend + Backend ASG)"
  type        = list(string)
  # Example: ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_data_subnet_cidrs" {
  description = "CIDR blocks for private data subnets (RDS)"
  type        = list(string)
  # Example: ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (cheaper) vs one per AZ (HA). Set false for prod."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default     = {}
}

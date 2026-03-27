# modules/bastion/variables.tf

variable "project" { type = string }

variable "public_subnet_id" {
  description = "Public subnet to launch bastion in"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security group ID for bastion"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 Key Pair name (already created in AWS Console)"
  type        = string
}

variable "instance_type" {
  description = "Bastion instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Override AMI (leave empty to use latest Amazon Linux 2023)"
  type        = string
  default     = ""
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

# ── outputs.tf ─────────────────────────────────────────────

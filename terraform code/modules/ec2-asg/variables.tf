# modules/ec2-asg/variables.tf

variable "project" { type = string }

variable "tier" {
  description = "frontend or backend — used in all resource names"
  type        = string
}

variable "vpc_id" { type = string }

variable "private_subnet_ids" {
  description = "Private app subnets for ASG instances"
  type        = list(string)
}

variable "ec2_sg_id" {
  description = "Security group ID for EC2 instances in this ASG"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN to attach this ASG to"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 Key Pair for SSH access via Bastion"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  # Use latest Amazon Linux 2023: ami-0c02fb55956c7d316 (us-east-1)
  # Or use a data source to always get latest
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of instances at launch"
  type        = number
  default     = 2
}

variable "scale_out_cpu_threshold" {
  description = "CPU % to trigger scale OUT"
  type        = number
  default     = 70
}

variable "scale_in_cpu_threshold" {
  description = "CPU % to trigger scale IN"
  type        = number
  default     = 30
}

variable "user_data_base64" {
  description = "Base64-encoded user data script. Leave empty for default."
  type        = string
  default     = ""
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

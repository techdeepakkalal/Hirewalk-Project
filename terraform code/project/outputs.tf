# environments/prod/outputs.tf

output "bastion_ssh_command" {
  description = "SSH into bastion host"
  value       = module.bastion.ssh_command
}

output "bastion_jump_example" {
  description = "SSH to private EC2 via bastion"
  value       = module.bastion.ssh_jump_example
}

output "app_url" {
  description = "Your application URL"
  value       = "https://${var.domain_name}"
}

output "cloudfront_domain" {
  description = "CloudFront domain (use before DNS propagates)"
  value       = "https://${module.cloudfront.cloudfront_domain_name}"
}

output "frontend_alb_dns" {
  description = "Frontend ALB DNS (internal reference)"
  value       = module.frontend_alb.alb_dns_name
}

output "backend_alb_dns" {
  description = "Backend ALB DNS (internal reference)"
  value       = module.backend_alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint for app config"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "rds_address" {
  value     = module.rds.db_address
  sensitive = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  value = module.vpc.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  value = module.vpc.private_data_subnet_ids
}

output "frontend_asg_name" {
  value = module.frontend_asg.asg_name
}

output "backend_asg_name" {
  value = module.backend_asg.asg_name
}

# output "route53_name_servers" {
#   description = "Update these at your domain registrar if zone was created by Terraform"
#   value       = module.route53.name_servers
# }

output "cloudfront_distribution_id" {
  description = "For cache invalidation: aws cloudfront create-invalidation --distribution-id <id> --paths '/*'"
  value       = module.cloudfront.cloudfront_distribution_id
}

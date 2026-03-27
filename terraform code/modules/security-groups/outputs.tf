# modules/security-groups/outputs.tf

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "frontend_alb_sg_id" {
  value = aws_security_group.frontend_alb.id
}

output "backend_alb_sg_id" {
  value = aws_security_group.backend_alb.id
}

output "frontend_ec2_sg_id" {
  value = aws_security_group.frontend_ec2.id
}

output "backend_ec2_sg_id" {
  value = aws_security_group.backend_ec2.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

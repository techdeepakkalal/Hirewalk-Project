# modules/bastion/outputs.tf

output "bastion_public_ip" {
  description = "Bastion Elastic IP"
  value       = aws_eip.bastion.public_ip
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "ssh_command" {
  description = "SSH into bastion"
  value       = "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_eip.bastion.public_ip}"
}

output "ssh_jump_example" {
  description = "Jump to private EC2 via bastion"
  value       = "ssh -J ec2-user@${aws_eip.bastion.public_ip} ec2-user@<private-ec2-ip>"
}

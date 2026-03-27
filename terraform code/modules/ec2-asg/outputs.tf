# modules/ec2-asg/outputs.tf

output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "asg_arn" {
  value = aws_autoscaling_group.this.arn
}

output "launch_template_id" {
  value = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.this.latest_version
}

output "iam_role_arn" {
  description = "IAM role ARN of EC2 instances in this ASG"
  value       = aws_iam_role.ec2.arn
}

output "iam_instance_profile_arn" {
  value = aws_iam_instance_profile.ec2.arn
}

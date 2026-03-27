# ============================================================
# modules/bastion/main.tf
# Bastion Host — SSH jump server in public subnet
# To connect to private resources: ssh -J ec2-user@<bastion-ip> ec2-user@<private-ip>
# ============================================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = coalesce(var.ami_id, data.aws_ami.amazon_linux.id)
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = var.key_pair_name

  # Disable outbound access to other internal resources except what SG allows
  associate_public_ip_address = true

  # Minimal user data — just enable SSH agent forwarding support
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    # Enable SSH Agent Forwarding
    echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config
    systemctl restart sshd
  EOF

  metadata_options {
    http_tokens                 = "required" # IMDSv2 required (security)
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(var.common_tags, { Name = "${var.project}-bastion" })
}

# ── Elastic IP for Bastion (stable IP for firewall rules) ──
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"
  tags     = merge(var.common_tags, { Name = "${var.project}-bastion-eip" })
}

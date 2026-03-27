# ============================================================
# modules/security-groups/main.tf
# ============================================================

# ── Bastion Host SG ─────────────────────────────────────────
resource "aws_security_group" "bastion" {
  name        = "${var.project}-bastion-sg"
  description = "Bastion - SSH from allowed IPs only"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from allowed CIDRs only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.project}-bastion-sg" })
}

# ── Frontend ALB SG ─────────────────────────────────────────
# Internet se traffic leta hai (CloudFront se)
resource "aws_security_group" "frontend_alb" {
  name        = "${var.project}-frontend-alb-sg"
  description = "Frontend ALB - HTTP/HTTPS from internet (CloudFront)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.project}-frontend-alb-sg" })
}

# ── Frontend EC2 SG ─────────────────────────────────────────
# Sirf Frontend ALB se traffic leta hai
resource "aws_security_group" "frontend_ec2" {
  name        = "${var.project}-frontend-ec2-sg"
  description = "Frontend EC2 - traffic from Frontend ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from Frontend ALB"
    from_port       = var.frontend_port
    to_port         = var.frontend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_alb.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.project}-frontend-ec2-sg" })
}

# ── Backend ALB SG ──────────────────────────────────────────
# SIRF Frontend EC2 se /api/* traffic leta hai
# Internet se direct access NAHI
resource "aws_security_group" "backend_alb" {
  name        = "${var.project}-backend-alb-sg"
  description = "Backend ALB - ONLY from Frontend EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "API traffic from Frontend EC2 only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.project}-backend-alb-sg" })
}

# ── Backend EC2 SG ──────────────────────────────────────────
# Sirf Backend ALB se traffic leta hai port 5000 pe
resource "aws_security_group" "backend_ec2" {
  name        = "${var.project}-backend-ec2-sg"
  description = "Backend EC2 - port 5000 from Backend ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Flask app port from Backend ALB"
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_alb.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.project}-backend-ec2-sg" })
}

# ── RDS SG ──────────────────────────────────────────────────
# Sirf Backend EC2 se MySQL traffic leta hai
resource "aws_security_group" "rds" {
  name        = "${var.project}-rds-sg"
  description = "RDS - MySQL from Backend EC2 only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from Backend EC2 only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_ec2.id]
  }

  dynamic "ingress" {
    for_each = var.allow_bastion_db_access ? [1] : []
    content {
      description     = "MySQL from Bastion (debug only)"
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = [aws_security_group.bastion.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.project}-rds-sg" })
}

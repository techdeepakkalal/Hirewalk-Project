# ============================================================
# modules/alb/main.tf
# Reusable ALB module — use once for frontend, once for backend
# Supports HTTP → HTTPS redirect + ACM certificate
# ============================================================

# ── Application Load Balancer ───────────────────────────────
resource "aws_lb" "this" {
  name               = "${var.project}-${var.tier}-alb"
  internal           = var.internal # false for frontend, true for backend
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnet_ids # public for frontend, private for backend

  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = true # Security best practice

  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = "${var.project}-${var.tier}-alb"
    enabled = var.access_logs_bucket != "" ? true : false
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.tier}-alb"
    Tier = var.tier
  })
}

# ── Target Group ────────────────────────────────────────────
resource "aws_lb_target_group" "this" {
  name        = "${var.project}-${var.tier}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = var.enable_stickiness
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.tier}-tg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ── HTTP Listener (redirects to HTTPS if cert provided) ────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.certificate_arn != "" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.certificate_arn == "" ? [1] : []
      content {
        target_group {
          arn = aws_lb_target_group.this.arn
        }
      }
    }
  }
}

# ── HTTPS Listener (only created if certificate_arn provided) ──
resource "aws_lb_listener" "https" {
  count = var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# ============================================================
# modules/ec2-asg/main.tf
# Reusable Auto Scaling Group module
# Use once for frontend, once for backend
# ============================================================

# ── IAM Role for EC2 (SSM + CloudWatch) ────────────────────
resource "aws_iam_role" "ec2" {
  name = "${var.project}-${var.tier}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project}-${var.tier}-ec2-profile"
  role = aws_iam_role.ec2.name
  tags = var.common_tags
}

# ── Launch Template ─────────────────────────────────────────
resource "aws_launch_template" "this" {
  name_prefix   = "${var.project}-${var.tier}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  vpc_security_group_ids = [var.ec2_sg_id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }

  # IMDSv2 required (security best practice)
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # User data — base64 encoded startup script
  user_data = var.user_data_base64 != "" ? var.user_data_base64 : base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    # Install CloudWatch agent
    yum install -y amazon-cloudwatch-agent
    # ─────────────────────────────────────────────────
    # ADD YOUR APP STARTUP COMMANDS HERE
    # Example for Node.js:
    #   curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    #   yum install -y nodejs
    #   cd /app && npm install && npm start
    # ─────────────────────────────────────────────────
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project}-${var.tier}-ec2"
      Tier = var.tier
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.common_tags, {
      Name = "${var.project}-${var.tier}-volume"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Auto Scaling Group ──────────────────────────────────────
resource "aws_autoscaling_group" "this" {
  name = "${var.project}-${var.tier}-asg"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.private_subnet_ids # Private subnets only
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  # Rolling updates — replace instances gradually
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }
  }

  dynamic "tag" {
    for_each = merge(var.common_tags, {
      Name = "${var.project}-${var.tier}-asg"
      Tier = var.tier
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity] # Let ASG manage this
  }
}

# ── Auto Scaling Policies ───────────────────────────────────

# Scale OUT — add instance when CPU > 70%
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project}-${var.tier}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project}-${var.tier}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scale_out_cpu_threshold
  alarm_description   = "Scale out when CPU > ${var.scale_out_cpu_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  tags = var.common_tags
}

# Scale IN — remove instance when CPU < 30%
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project}-${var.tier}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project}-${var.tier}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scale_in_cpu_threshold
  alarm_description   = "Scale in when CPU < ${var.scale_in_cpu_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  tags = var.common_tags
}

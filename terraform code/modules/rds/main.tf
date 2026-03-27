# ============================================================
# modules/rds/main.tf
# RDS MySQL — Multi-AZ, Private, Encrypted, with subnet group
# ============================================================

resource "aws_db_subnet_group" "this" {
  name        = "${var.project}-db-subnet-group"
  subnet_ids  = var.private_data_subnet_ids
  description = "Private data subnets for RDS"

  tags = merge(var.common_tags, { Name = "${var.project}-db-subnet-group" })
}

# ── Parameter Group (tune MySQL settings here) ─────────────
resource "aws_db_parameter_group" "this" {
  name        = "${var.project}-mysql-params"
  family      = "mysql8.0"
  description = "${var.project} MySQL parameter group"

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  tags = var.common_tags
}

# ── RDS Instance ────────────────────────────────────────────
resource "aws_db_instance" "this" {
  identifier = "${var.project}-db"

  # Engine
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn # null = AWS managed key

  # Database
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false # NEVER true in prod

  # High Availability
  multi_az = var.multi_az

  # Backup & Maintenance
  backup_retention_period   = var.backup_retention_days
  backup_window             = "03:00-04:00"
  maintenance_window        = "Mon:04:00-Mon:05:00"
  copy_tags_to_snapshot     = true
  final_snapshot_identifier = "${var.project}-db-final-snapshot"
  skip_final_snapshot       = var.skip_final_snapshot

  # Performance & Monitoring
  parameter_group_name        = aws_db_parameter_group.this.name
  performance_insights_enabled = var.enable_performance_insights
  enabled_cloudwatch_logs_exports = ["error", "slowquery", "general"]

  # Security
  deletion_protection = var.deletion_protection
  auto_minor_version_upgrade = true

  tags = merge(var.common_tags, { Name = "${var.project}-db" })
}

# ── CloudWatch Alarms for RDS ──────────────────────────────
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU > 80%"
  alarm_actions       = var.alarm_sns_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${var.project}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120 # 5 GB in bytes
  alarm_description   = "RDS free storage < 5GB"
  alarm_actions       = var.alarm_sns_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }

  tags = var.common_tags
}

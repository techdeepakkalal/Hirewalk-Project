# ============================================================
# global/backend-bootstrap/main.tf
# Run this ONCE before everything else to create:
#   - S3 bucket for Terraform state
#   - DynamoDB table for state locking
# ============================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # NOTE: No backend block here — this bootstraps the backend itself!
}

provider "aws" {
  region = var.aws_region
}

# ── S3 Bucket for Terraform State ──────────────────────────
resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.common_tags, { Name = var.state_bucket_name })
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── DynamoDB Table for State Locking ───────────────────────
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.common_tags, { Name = var.lock_table_name })
}

# ── Outputs (copy these into your environment backend config) ──
output "state_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}

output "lock_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}

output "backend_config_snippet" {
  value = <<-EOT
    # Paste this into your environment's backend.tf:
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.tf_state.bucket}"
        key            = "<project>/<env>/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.tf_lock.name}"
        encrypt        = true
      }
    }
  EOT
}

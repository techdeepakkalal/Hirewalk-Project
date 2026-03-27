# ============================================================
# modules/route53/main.tf
# Route53: Hosted Zone + DNS records pointing to CloudFront
# ============================================================

# ── Data source for existing hosted zone (if already exists) ──
data "aws_route53_zone" "this" {
  count        = var.create_zone ? 0 : 1
  name         = var.domain_name
  private_zone = false
}

# ── Create new hosted zone (if it doesn't exist yet) ───────
resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0
  name  = var.domain_name
  tags  = merge(var.common_tags, { Name = var.domain_name })
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.this[0].zone_id
}

# ── Root domain → CloudFront (e.g. hirewalk.com) ───────────
resource "aws_route53_record" "root" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# ── www subdomain → CloudFront ─────────────────────────────
resource "aws_route53_record" "www" {
  count   = var.create_www_record ? 1 : 0
  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# ── ACM Certificate DNS Validation records ─────────────────
resource "aws_route53_record" "acm_validation" {
  for_each = var.acm_validation_records

  zone_id = local.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

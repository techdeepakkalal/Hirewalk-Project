# ============================================================
# modules/cloudfront/main.tf
# CloudFront distribution with:
#   - Primary origin: Frontend ALB
#   - API origin: Backend ALB  (/api/* path pattern)
#   - WAF integration (optional)
#   - Custom domain + ACM certificate
# ============================================================

locals {
  frontend_origin_id = "${var.project}-frontend-alb-origin"
  backend_origin_id  = "${var.project}-backend-alb-origin"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project} CloudFront Distribution"
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.domain_aliases # e.g. ["hirewalk.com", "www.hirewalk.com"]
  web_acl_id          = var.waf_web_acl_arn # optional WAF

  # ── Origin 1: Frontend ALB ─────────────────────────────
  origin {
    domain_name = var.frontend_alb_dns_name
    origin_id   = local.frontend_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = var.frontend_alb_https ? "https-only" : "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "X-Custom-Header"
      value = var.origin_secret_header # prevents direct ALB access
    }
  }

  # ── Origin 2: Backend ALB ──────────────────────────────
  origin {
    domain_name = var.backend_alb_dns_name
    origin_id   = local.backend_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # backend ALB is internal HTTP
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "X-Custom-Header"
      value = var.origin_secret_header
    }
  }

  # ── Default Cache Behaviour: Frontend ─────────────────
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.frontend_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin", "Authorization"]
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = var.frontend_default_ttl
    max_ttl     = var.frontend_max_ttl
  }

  # ── Ordered Cache Behaviour: /api/* → Backend ALB ──────
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.backend_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = false

    forwarded_values {
      query_string = true
      headers      = ["*"] # Forward all headers to backend API
      cookies {
        forward = "all"
      }
    }

    # No caching for API responses
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # ── Static assets cache behaviour (/static/*, *.js, *.css) ──
  ordered_cache_behavior {
    path_pattern           = "/static/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.frontend_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 86400    # 1 day
    default_ttl = 604800   # 7 days
    max_ttl     = 31536000 # 1 year
  }

  # ── Geo Restrictions ───────────────────────────────────
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type # "none", "whitelist", "blacklist"
      locations        = var.geo_restriction_locations
    }
  }

  # ── SSL/TLS Certificate ────────────────────────────────
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
    ssl_support_method       = var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version = var.acm_certificate_arn != "" ? "TLSv1.2_2021" : null
  }

  # ── Custom Error Pages ─────────────────────────────────
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html" # SPA support
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html" # SPA support
    error_caching_min_ttl = 10
  }

  tags = merge(var.common_tags, { Name = "${var.project}-cloudfront" })
}

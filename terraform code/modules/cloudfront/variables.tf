# modules/cloudfront/variables.tf

variable "project" { type = string }

variable "frontend_alb_dns_name" {
  description = "Frontend ALB DNS name"
  type        = string
}

variable "backend_alb_dns_name" {
  description = "Backend ALB DNS name"
  type        = string
}

variable "frontend_alb_https" {
  description = "Set true if frontend ALB has HTTPS listener"
  type        = bool
  default     = false
}

variable "domain_aliases" {
  description = "Custom domains for CloudFront (e.g. ['example.com', 'www.example.com'])"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (must be in us-east-1 for CloudFront)"
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "PriceClass_All | PriceClass_200 | PriceClass_100"
  type        = string
  default     = "PriceClass_100" # US, Canada, Europe only (cheapest)
}

variable "origin_secret_header" {
  description = "Secret value passed as X-Custom-Header to ALB origins. ALB can verify this to block direct access."
  type        = string
  sensitive   = true
  default     = "change-me-random-secret-value"
}

variable "frontend_default_ttl" {
  type    = number
  default = 3600 # 1 hour
}

variable "frontend_max_ttl" {
  type    = number
  default = 86400 # 24 hours
}

variable "geo_restriction_type" {
  description = "none | whitelist | blacklist"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "ISO 3166-1 alpha-2 country codes (used only if restriction_type != none)"
  type        = list(string)
  default     = []
}

variable "waf_web_acl_arn" {
  description = "WAF Web ACL ARN to attach to CloudFront (optional)"
  type        = string
  default     = null
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

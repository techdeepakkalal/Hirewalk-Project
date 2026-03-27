# modules/route53/variables.tf

variable "project" { type = string }

variable "domain_name" {
  description = "Your root domain (e.g. hirewalk.com)"
  type        = string
}

variable "create_zone" {
  description = "true = create new hosted zone | false = use existing zone"
  type        = bool
  default     = false
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
}

variable "cloudfront_hosted_zone_id" {
  description = "CloudFront hosted zone ID (for alias record)"
  type        = string
}

variable "create_www_record" {
  description = "Also create www.domain alias"
  type        = bool
  default     = true
}

variable "acm_validation_records" {
  description = "Map of ACM DNS validation records. Pass from aws_acm_certificate domain_validation_options."
  type = map(object({
    name   = string
    type   = string
    record = string
  }))
  default = {}
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

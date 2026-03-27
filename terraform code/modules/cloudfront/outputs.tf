# modules/cloudfront/outputs.tf

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain (e.g. d1234.cloudfront.net)"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront hosted zone ID — for Route53 alias records"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.this.arn
}

# modules/route53/outputs.tf

output "zone_id" {
  description = "Route53 Hosted Zone ID"
  value       = local.zone_id
}

output "name_servers" {
  description = "Name servers — update these at your domain registrar if zone was created here"
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : []
}

output "root_record_fqdn" {
  value = aws_route53_record.root.fqdn
}

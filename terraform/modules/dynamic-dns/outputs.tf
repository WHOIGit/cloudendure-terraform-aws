output "zone_id" {
  description = "Zone ID"
  value       = data.aws_route53_zone.this.zone_id
}

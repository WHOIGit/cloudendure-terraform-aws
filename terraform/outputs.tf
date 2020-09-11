# Staging VPC
output "vpc_staging_id" {
  description = "ID of the Staging VPC"
  value       = module.vpc_staging.vpc_id
}

output "vpc_staging_public_subnets" {
  description = "IDs of the Staging VPC's public subnets"
  value       = module.vpc_staging.public_subnets
}

# External Site Target VPC
output "vpc_external_id" {
  description = "ID of the Staging VPC"
  value       = module.vpc_external.vpc_id
}

output "vpc_external_public_subnets" {
  description = "IDs of the Staging VPC's public subnets"
  value       = module.vpc_external.public_subnets
}

# Internal Site Target VPC
output "vpc_internal_id" {
  description = "ID of the Staging VPC"
  value       = module.vpc_internal.vpc_id
}

output "vpc_internal_public_subnets" {
  description = "IDs of the Staging VPC's public subnets"
  value       = module.vpc_internal.public_subnets
}

# DNS output
output "dynamic_dns_whoi_it" {
  description = "Zone ID for whoi-it.whoi.edu"
  value       = module.dynamic_dns_whoi_it.zone_id
}

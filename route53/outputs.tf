################################################################################
# Public Zones
################################################################################

output "route53_main_zone_id" {
  description = "Zone ID of main Route53 zone"
  value       = module.main.id
}

output "route53_main_zone_arn" {
  description = "ARN of main Route53 zone"
  value       = module.main.arn
}

output "route53_legacy_zone_id" {
  description = "Zone ID of legacy Route53 zone"
  value       = module.legacy.id
}

output "route53_legacy_zone_arn" {
  description = "ARN of legacy Route53 zone"
  value       = module.legacy.arn
}

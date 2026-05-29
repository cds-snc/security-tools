output "internal_hosted_zone_id" {
  description = "The internal hosted zone id"
  value       = aws_service_discovery_private_dns_namespace.internal.hosted_zone
}

output "hosted_zone_id" {
  description = "Route53 hosted zone ID that will hold all DNS records"
  value       = aws_route53_zone.base_hosted_zone.zone_id
}

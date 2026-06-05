output "hosted_zone_id" {
  description = "Route53 hosted zone ID that will hold all DNS records"
  value       = aws_route53_zone.base_hosted_zone.id
}

output "hosted_zone_certificate_arn" {
  description = "ACM certificate ARN for the hosted zone"
  value       = aws_acm_certificate.base_hosted_zone.arn
}

output "security_tools_vpc_id" {
  description = "The VPC ID for the security tools"
  value       = module.vpc.vpc_id
}

output "service_discovery_namespace_arn" {
  description = "ARN for the ECS Service Connect HTTP namespace"
  value       = aws_service_discovery_http_namespace.internal_mesh.arn
}

output "service_discovery_namespace_id" {
  description = "ID for the ECS Service Connect HTTP namespace"
  value       = aws_service_discovery_http_namespace.internal_mesh.id
}

output "vpc_main_nacl_id" {
  description = "The VPC main network ACL ID"
  value       = module.vpc.main_nacl_id
}

output "vpc_private_subnet_cidrs" {
  description = "The private subnet CIDRs for the VPC"
  value       = module.vpc.private_subnet_cidr_blocks
}

output "vpc_public_subnet_cidrs" {
  description = "The public subnet CIDRs for the VPC"
  value       = module.vpc.public_subnet_cidr_blocks
}

output "vpc_private_subnet_ids" {
  description = "The private subnet IDs for the VPC"
  value       = module.vpc.private_subnet_ids
}

output "vpc_public_subnet_ids" {
  description = "The public subnet IDs for the VPC"
  value       = module.vpc.public_subnet_ids
}

# ----------------------------------------------------------------#
# ECR Repository URLs
# ----------------------------------------------------------------#

output "cartography_repository_url" {
  description = "ECR repository URL for Cartography"
  value       = aws_ecr_repository.cartography.repository_url
}

output "neo4j_repository_url" {
  description = "ECR repository URL for Neo4j"
  value       = aws_ecr_repository.neo4j.repository_url
}

output "pomerium_sso_proxy_repository_url" {
  description = "ECR repository URL for Pomerium SSO Proxy"
  value       = aws_ecr_repository.sso_proxy_pomerium.repository_url
}

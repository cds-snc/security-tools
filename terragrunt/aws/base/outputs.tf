output "security_tools_vpc_id" {
  description = "The VPC ID for the security tools"
  value       = module.vpc.vpc_id
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

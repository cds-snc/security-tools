variable "cloud_asset_inventory_vpc_peering_connection_id" {
  description = "The VPC peering connection ID for Cloud Asset Inventory"
  type        = string
}

variable "security_tools_vpc_id" {
  description = "(Required) The VPC ID for the security tools"
  type        = string
}

variable "ssm_prefix" {
  description = "(Required) Prefix to apply to all key names"
  type        = string
  default     = "cloudquery"
}

variable "customer_id" {
  description = "(Required) Azure log workspace customer ID"
  sensitive   = true
  type        = string
}

variable "shared_key" {
  description = "(Required) Azure log workspace shared key"
  sensitive   = true
  type        = string
}

variable "cloudquery_api_key" {
  description = "(Required) Cloudquery API key"
  sensitive = true
  type        = string
}

variable "vpc_private_subnet_cidrs" {
  description = "(Required) The private subnet CIDRs for the VPC"
  type        = list(string)
}

variable "vpc_public_subnet_cidrs" {
  description = "(Required) The public subnet CIDRs for the VPC"
  type        = list(string)
}

variable "vpc_private_subnet_ids" {
  description = "(Required) The private subnet IDs for the VPC"
  type        = list(string)
}

variable "vpc_public_subnet_ids" {
  description = "(Required) The public subnet IDs for the VPC"
  type        = list(string)
}

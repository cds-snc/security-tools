variable "asset_inventory_managed_accounts" {
  description = "(Optional) List of AWS accounts to manage cloud asset inventory for."
  type        = list(string)
  default     = []
}

variable "cloud_asset_inventory_vpc_peering_connection_id" {
  description = "The VPC peering connection ID for Cloud Asset Inventory"
  type        = string
}

variable "customer_id" {
  description = "(Required) Azure log workspace customer ID"
  sensitive   = true
  type        = string
}

variable "neo4j_image" {
  description = "(Required) The neo4j image to use"
  type        = string
}

variable "neo4j_image_tag" {
  description = "(Required) The neo4j image tag to use"
  type        = string
}

variable "neo4j_password" {
  description = "(Required) The neo4j password"
  sensitive   = true
  type        = string
}

variable "password_change_id" {
  description = "(Required) Id to trigger changing the neo4j password."
  type        = string
}

variable "security_tools_vpc_id" {
  description = "(Required) The VPC ID for the security tools"
  type        = string
}

variable "shared_key" {
  description = "(Required) Azure log workspace shared secret"
  sensitive   = true
  type        = string
}

variable "ssm_prefix" {
  description = "(Required) Prefix to apply to all key names"
  type        = string
  default     = "cloudquery"
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

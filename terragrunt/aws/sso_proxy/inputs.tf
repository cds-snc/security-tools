variable "cloud_asset_inventory_load_balancer_dns" {
  description = "DNS name for Cloud Asset Inventory Load Balancer"
  type        = string
}

variable "software_asset_inventory_load_balancer_dns" {
  description = "DNS name for Software Asset Inventory Load Balancer"
  type        = string
}

variable "csp_violation_report_service_load_balancer_dns" {
  description = "DNS name for CSP Report Load Balancer"
  type        = string
}

variable "pomerium_client_id" {
  description = "The pomerium client id"
  type        = string
  sensitive   = true
}

variable "pomerium_client_secret" {
  description = "The pomerium client secret"
  type        = string
  sensitive   = true
}

variable "pomerium_image" {
  description = "The pomerium image to use"
  type        = string
}

variable "pomerium_image_tag" {
  description = "The pomerium image tag to use"
  type        = string
}

variable "pomerium_google_client_id" {
  description = "The pomerium google sso client id"
  type        = string
  sensitive   = true
}

variable "pomerium_google_client_secret" {
  description = "The pomerium google sso client secret"
  type        = string
  sensitive   = true
}

variable "pomerium_verify_image" {
  description = "The pomerium verify image to use for the sso proxy"
  type        = string
}

variable "pomerium_verify_image_tag" {
  description = "The pomerium verify image tag to use"
  type        = string
}

variable "security_tools_vpc_id" {
  description = "(Required) The VPC ID for the security tools"
  type        = string
}

variable "session_cookie_expires_in" {
  description = "The duration the pomerium session cookie should last"
  type        = string
}

variable "session_cookie_secret" {
  description = "The pomerium seed string for secure cookies"
  type        = string
  sensitive   = true
}

variable "session_key" {
  description = "The pomerium auth session key"
  type        = string
  sensitive   = true
}

variable "ssm_prefix" {
  description = "(Required) Prefix to apply to all key names"
  type        = string
  default     = "sso_proxy"
}

variable "vpc_main_nacl_id" {
  description = "(Required) The VPC main network ACL ID"
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

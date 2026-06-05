variable "hosted_zone_id" {
  description = "(Required) The Route53 hosted zone ID for the security tools domain"
  type        = string
}

variable "hosted_zone_certificate_arn" {
  description = "(Required) The ARN of the ACM certificate for the security tools hosted zone"
  type        = string
}

variable "service_discovery_namespace_arn" {
  description = "(Required) The ARN of the ECS Service Connect HTTP namespace for internal service discovery"
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

variable "security_tools_vpc_id" {
  description = "(Required) The VPC ID for the security tools"
  type        = string
}

variable "security_tools_domain_name" {
  description = "(Required) The domain name to use for security tools"
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

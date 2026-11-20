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

variable "oauth2_proxy_image" {
  description = "The mirrored oauth2-proxy ECR repository URL"
  type        = string
}

variable "oauth2_proxy_image_digest" {
  description = "The SHA-256 manifest digest of the mirrored oauth2-proxy image"
  type        = string

  validation {
    condition     = can(regex("^sha256:[0-9a-f]{64}$", var.oauth2_proxy_image_digest))
    error_message = "Pin oauth2-proxy with a full sha256:<64 lowercase hex characters> image digest, not a tag."
  }
}

variable "google_client_id" {
  description = "The Google OAuth client ID for interactive Neo4j access"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "The Google OAuth client secret for interactive Neo4j access"
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
  description = "The duration the oauth2-proxy session cookie should last"
  type        = string
}

variable "oauth2_proxy_cookie_secret" {
  description = "A new base64-encoded 32-byte secret shared by both oauth2-proxy containers"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[A-Za-z0-9+/]{43}=$", var.oauth2_proxy_cookie_secret))
    error_message = "Generate a base64-encoded 32-byte cookie secret with openssl rand -base64 32."
  }
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

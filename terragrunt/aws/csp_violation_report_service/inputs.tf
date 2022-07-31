variable "security_tools_vpc_id" {
  description = "(Required) The VPC ID for the security tools"
  type        = string
}

variable "ssm_prefix" {
  description = "(Required) Prefix to apply to all key names"
  type        = string
  default     = "csp_reports"
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

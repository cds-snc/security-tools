variable "aws_org_id" {
  description = "The AWS org account ID.  Used to limit which accounts can access the public repository."
  type        = string
  sensitive   = true
}

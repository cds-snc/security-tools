module "cloudquery_s3_bucket" {
  source = "github.com/cds-snc/terraform-modules?ref=v5.1.4//s3"
  name   = "security-tools-794722365809-cloudquery-results"

  versioning = true

  lifecycle_rule {
    enabled = true
    id      = "delete-old-versions"
    prefix  = ""

    noncurrent_version_expiration {
      days = 30
    }
  }

  billing_tag_key    = var.billing_tag_key
  billing_tag_value  = var.billing_tag_value
  critical_tag_key   = var.critical_tag_key
  critical_tag_value = var.critical_tag_value
}
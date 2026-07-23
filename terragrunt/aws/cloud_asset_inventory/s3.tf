# S3 bucket holding the curated cartography security exports.

module "sentinel_exports" {
  source = "github.com/cds-snc/terraform-modules//S3?ref=v11.4.4"

  bucket_name       = "${var.product_name}-${var.tool_name}-sentinel-exports"
  billing_tag_key   = var.billing_tag_key
  billing_tag_value = var.billing_tag_value

  tags = {
    Terraform = "true"
    Product   = "${var.product_name}-${var.tool_name}"
  }

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id      = "expire-exports"
      enabled = true
      expiration = {
        days = 14
      }
      noncurrent_version_expiration = {
        days = 7
      }
    }
  ]
}

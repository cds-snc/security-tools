locals {
  name_prefix     = "${var.product_name}-${var.account_id}"
  cloudquery_name = "${local.name_prefix}-cloudquery-results"
}

module "cloudquery_s3_bucket" {
  source      = "github.com/cds-snc/terraform-modules?ref=v5.1.4//S3"
  bucket_name = local.cloudquery_name

  billing_tag_key   = var.billing_tag_key
  billing_tag_value = var.billing_tag_value
  # critical_tag_key   = var.critical_tag_key
  # critical_tag_value = var.critical_tag_value
}
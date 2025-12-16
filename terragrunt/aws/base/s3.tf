locals {
  name_prefix = "${var.product_name}-${var.account_id}"
  athena_name = "${local.name_prefix}-athena-query-results"
}

module "log_bucket" {
  source            = "github.com/cds-snc/terraform-modules//S3_log_bucket?ref=v8.0.0"
  bucket_name       = "${local.name_prefix}-logs"
  billing_tag_value = var.billing_tag_value
}

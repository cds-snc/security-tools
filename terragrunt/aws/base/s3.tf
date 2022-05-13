locals {
  name_prefix = "${var.product_name}-${var.account_id}"
  athena_name = "${local.name_prefix}-athena-query-results"
}

module "log_bucket" {
  source            = "github.com/cds-snc/terraform-modules?ref=v0.0.47//S3_log_bucket"
  bucket_name       = "${local.name_prefix}-logs"
  billing_tag_value = var.billing_tag_value
}

module "athena" {
  source      = "github.com/cds-snc/terraform-modules?ref=v0.0.47//S3"
  bucket_name = local.athena_name
  lifecycle_rule = [{
    id      = "expire"
    enabled = true
    expiration = {
      days = 7
    }
  }]
  billing_tag_value = var.billing_tag_value
  logging = {
    "target_bucket" = module.log_bucket.s3_bucket_id
    "target_prefix" = local.athena_name
  }
}

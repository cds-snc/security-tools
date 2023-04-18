module "sentinel_forwarder" {
  source = "github.com/cds-snc/terraform-modules?ref=v5.1.4//sentinel_forwarder"

  function_name = "cloudquery-sentinel-forwarder"
  customer_id   = var.customer_id
  shared_key    = var.shared_key

  log_type = local.cloudquery_service_name

  layer_arn = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:56"

  s3_sources = [
    {
      bucket_arn    = module.cloudquery_s3_bucket.s3_bucket_arn
      bucket_id     = module.cloudquery_s3_bucket.s3_bucket_id
      filter_prefix = "cloudquery/"
      kms_key_arn   = data.aws_kms_key.s3_bucket_kms_key.arn
    }
  ]

  billing_tag_key   = var.billing_tag_key
  billing_tag_value = var.billing_tag_value
}
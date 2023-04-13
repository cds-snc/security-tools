module "cloudquery_s3_bucket" {
  source      = "github.com/cds-snc/terraform-modules?ref=v5.1.4//S3"
  bucket_name = local.cloudquery_name

  billing_tag_key   = var.billing_tag_key
  billing_tag_value = var.billing_tag_value

  kms_key_arn = data.aws_kms_key.s3_bucket_kms_key.arn

  versioning = {
    enabled = true
  }
}

data "aws_kms_key" "s3_bucket_kms_key" {
  key_id = "alias/aws/s3"
}

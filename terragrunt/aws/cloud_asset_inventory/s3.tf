# S3 bucket holding the curated cartography security views (JSON)

resource "aws_s3_bucket" "sentinel_exports" {
  bucket = "${var.product_name}-${var.tool_name}-sentinel-exports"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_s3_bucket_public_access_block" "sentinel_exports" {
  bucket                  = aws_s3_bucket.sentinel_exports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sentinel_exports" {
  bucket = aws_s3_bucket.sentinel_exports.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "sentinel_exports" {
  bucket = aws_s3_bucket.sentinel_exports.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "sentinel_exports" {
  bucket = aws_s3_bucket.sentinel_exports.id

  rule {
    id     = "expire-exports"
    status = "Enabled"
    filter {}
    expiration {
      days = 14
    }
    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

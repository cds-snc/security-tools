module "security_tools_binaries" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v10.11.0"
  bucket_name       = "cds-security-tools-binaries"
  billing_tag_value = var.billing_tag_value

  versioning = {
    enabled = true
  }
}

#
# Allow any IAM role in the CDS AWS org to read from the bucket
#
data "aws_iam_policy_document" "security_tools_binaries_policy" {
  statement {
    sid    = "OrgRead"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${module.security_tools_binaries.s3_bucket_arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.aws_org_id]
    }
  }
}

resource "aws_s3_bucket_policy" "security_tools_binaries" {
  bucket = module.security_tools_binaries.s3_bucket_id
  policy = data.aws_iam_policy_document.security_tools_binaries_policy.json
}
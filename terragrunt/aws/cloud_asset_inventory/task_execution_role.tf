###
# This role is used by the service running in the container to make API calls to AWS.
###


resource "aws_iam_role" "cloudquery_task_execution_role" {
  name               = local.asset_inventory_admin_role
  assume_role_policy = data.aws_iam_policy_document.cloudquery_task_execution_role.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

data "aws_iam_policy_document" "cloudquery_task_execution_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

### Task execution role policy

resource "aws_iam_role_policy_attachment" "cloudquery_task_execution_policies" {
  role       = aws_iam_role.cloudquery_task_execution_role.name
  policy_arn = aws_iam_policy.cloudquery_task_execution_policies.arn
}

data "aws_iam_policy_document" "cloudquery_task_execution_policies" {
  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]
    resources = ["arn:aws:iam::*:role/secopsAssetInventorySecurityAuditRole"]
  }

  statement {
    effect = "Allow"

    actions = [
      "organizations:ListAccounts",
      "organizations:ListAccountsForParent",
      "organizations:ListChildren"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "${module.cloudquery_s3_bucket.s3_bucket_arn}",
      "${module.cloudquery_s3_bucket.s3_bucket_arn}/*"
    ]

  }
}

resource "aws_iam_policy" "cloudquery_task_execution_policies" {
  name   = "CloudqueryTaskExecutionPolicies"
  path   = "/"
  policy = data.aws_iam_policy_document.cloudquery_task_execution_policies.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
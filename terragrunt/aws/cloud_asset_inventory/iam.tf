###
# The task execution role grants the Amazon ECS container and Fargate agents 
# permission to make AWS API calls on your behalf
###

locals {
  asset_inventory_admin_role         = "secopsAssetInventoryCartographyRole"
  organization_account_list_role_arn = "arn:aws:iam::${var.organization_management_account_id}:role/${var.organization_account_list_role_name}"
  cartography_spoke_role_arn         = "arn:aws:iam::*:role/${var.cartography_spoke_role_name}"
  sentinel_forward_oidc_role_name    = "sentinel-forwarder-s3-readonly"
}

data "aws_organizations_organization" "current" {}

module "sentinel_forward_oidc_role" {
  source = "github.com/cds-snc/terraform-modules//gh_oidc_role?ref=v11.3.5"

  billing_tag_key   = var.billing_tag_key
  billing_tag_value = var.billing_tag_value

  roles = [
    {
      name      = local.sentinel_forward_oidc_role_name
      repo_name = "security-tools"
      claim     = "ref:refs/heads/main"
    }
  ]
}

data "aws_iam_policy_document" "sentinel_forward_s3_readonly" {
  statement {
    sid    = "ListAndDescribeSentinelExportsBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]
    resources = [
      module.sentinel_exports.s3_bucket_arn,
    ]
  }

  statement {
    sid    = "ReadSentinelExportsObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = [
      "${module.sentinel_exports.s3_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_policy" "sentinel_forward_s3_readonly" {
  name   = "${var.product_name}-${var.tool_name}-SentinelForwardS3ReadOnly"
  path   = "/"
  policy = data.aws_iam_policy_document.sentinel_forward_s3_readonly.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_iam_role_policy_attachment" "sentinel_forward_s3_readonly" {
  role       = module.sentinel_forward_oidc_role.roles[local.sentinel_forward_oidc_role_name].name
  policy_arn = aws_iam_policy.sentinel_forward_s3_readonly.arn
}

resource "aws_iam_role" "cartography_task_execution_role" {
  name               = local.asset_inventory_admin_role
  assume_role_policy = data.aws_iam_policy_document.cartography_task_execution_role.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

data "aws_iam_policy_document" "cartography_task_execution_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.cartography_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policies" {
  role       = aws_iam_role.cartography_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registery_policies" {
  role       = aws_iam_role.cartography_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecs_container_registery_policies" {
  role       = aws_iam_role.cartography_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

### Task execution role policy

resource "aws_iam_role_policy_attachment" "cartography_task_execution_policies" {
  role       = aws_iam_role.cartography_task_execution_role.name
  policy_arn = aws_iam_policy.cartography_task_execution_policies.arn
}

data "aws_iam_policy_document" "cartography_task_execution_policies" {
  # Assume the read-only audit role in every member account (restricted to this org).
  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]
    resources = [local.cartography_spoke_role_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.current.id]
    }
  }

  # Assume the management-account role to enumerate accounts and sync the org hierarchy.
  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]
    resources = [local.organization_account_list_role_arn]
  }

  # Cartography enumerates the regions in use across accounts (hub-role requirement).
  statement {

    effect = "Allow"

    actions = [
      "ec2:DescribeRegions",
    ]
    resources = ["*"]
  }

  # The finalizer container writes the curated security exports to S3.
  statement {

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${module.sentinel_exports.s3_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_policy" "cartography_task_execution_policies" {
  name   = "CartographyTaskExecutionPolicies"
  path   = "/"
  policy = data.aws_iam_policy_document.cartography_task_execution_policies.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

### WAF IAM role

resource "aws_iam_role" "waf_log_role" {
  name               = "${var.product_name}-${var.tool_name}-logs"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_iam_policy" "write_waf_logs" {
  name        = "${var.product_name}-${var.tool_name}_WriteLogs"
  description = "Allow writing WAF logs to S3 + CloudWatch"
  policy      = data.aws_iam_policy_document.write_waf_logs.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_iam_role_policy_attachment" "write_waf_logs" {
  role       = aws_iam_role.waf_log_role.name
  policy_arn = aws_iam_policy.write_waf_logs.arn
}

data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "write_waf_logs" {
  statement {
    sid    = "S3PutObjects"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.cbs_satellite_bucket_name}/*"
    ]
  }
}

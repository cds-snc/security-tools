resource "aws_efs_file_system" "dependencytrack" {
  encrypted = true

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_efs_backup_policy" "dependencytrack" {
  file_system_id = aws_efs_file_system.dependencytrack.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "dependencytrack" {
  count           = length(var.vpc_private_subnet_ids)
  file_system_id  = aws_efs_file_system.dependencytrack.id
  subnet_id       = element(var.vpc_private_subnet_ids, count.index)
  security_groups = [aws_security_group.dependencytrack.id]
}

resource "aws_efs_access_point" "dependencytrack" {
  file_system_id = aws_efs_file_system.dependencytrack.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/data"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 775
    }
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_efs_file_system_policy" "dependencytrack" {
  file_system_id = aws_efs_file_system.dependencytrack.id
  policy         = data.aws_iam_policy_document.dependencytrack_efs_policy.json
}

data "aws_iam_policy_document" "dependencytrack_efs_policy" {
  statement {
    sid    = "AllowAccessThroughAccessPoint"
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]
    resources = [aws_efs_file_system.dependencytrack.arn]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "elasticfilesystem:AccessPointArn"
      values = [
        aws_efs_access_point.dependencytrack.arn
      ]
    }
  }

  statement {
    sid       = "DenyNonSecureTransport"
    effect    = "Deny"
    actions   = ["*"]
    resources = [aws_efs_file_system.dependencytrack.arn]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

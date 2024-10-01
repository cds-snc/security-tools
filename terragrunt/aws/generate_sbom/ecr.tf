resource "aws_ecr_repository" "generate_sbom" {
  name                 = "${var.product_name}/generate_sbom/trivy"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ecrpublic_repository" "generate_sbom_public" {
  provider        = aws.us-east-1
  repository_name = "${var.product_name}/generate_sbom_public/trivy"
  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
data "aws_iam_policy_document" "sbom_public_policy_document" {
  provider = aws.us-east-1
  statement {
    sid    = "sbom_public_policy"
    effect = "Allow"


    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.aws_org_id]
    }
  }
}
resource "aws_ecrpublic_repository_policy" "sbom_public_policy" {
  provider        = aws.us-east-1
  repository_name = aws_ecrpublic_repository.generate_sbom_public.repository_name
  policy          = data.aws_iam_policy_document.sbom_public_policy_document.json
}

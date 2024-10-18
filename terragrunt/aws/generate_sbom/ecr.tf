resource "aws_ecrpublic_repository" "generate_sbom_trivy_db" {
  provider        = aws.us-east-1
  repository_name = "${var.product_name}/generate_sbom/trivy-db"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ecrpublic_repository" "generate_sbom_trivy_java_db" {
  provider        = aws.us-east-1
  repository_name = "${var.product_name}/generate_sbom/trivy-java-db"

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
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchDeleteImage",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:SetRepositoryPolicy",
      "ecr:UploadLayerPart"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.aws_org_id]
    }
  }
}

#
# Attach the ECR IAM policy
#
resource "aws_ecrpublic_repository_policy" "generate_sbom_trivy_db" {
  provider        = aws.us-east-1
  repository_name = aws_ecrpublic_repository.generate_sbom_trivy_db.repository_name
  policy          = sensitive(data.aws_iam_policy_document.sbom_public_policy_document.json)
}

resource "aws_ecrpublic_repository_policy" "generate_sbom_trivy_java_db" {
  provider        = aws.us-east-1
  repository_name = aws_ecrpublic_repository.generate_sbom_trivy_java_db.repository_name
  policy          = sensitive(data.aws_iam_policy_document.sbom_public_policy_document.json)
}

#
# Policy to expire untagged images
#
resource "aws_ecr_lifecycle_policy" "generate_sbom_trivy_db" {
  provider   = aws.us-east-1
  repository = aws_ecrpublic_repository.generate_sbom_trivy_db.repository_name
  policy     = file("${path.module}/policy/lifecycle.json")
}

resource "aws_ecr_lifecycle_policy" "generate_sbom_trivy_java_db" {
  provider   = aws.us-east-1
  repository = aws_ecrpublic_repository.generate_sbom_trivy_java_db.repository_name
  policy     = file("${path.module}/policy/lifecycle.json")
}

moved {
  from = aws_ecr_repository.generate_sbom_public
  to   = aws_ecr_repository.generate_sbom_trivy_db
}

moved {
  from = aws_ecrpublic_repository_polic.sbom_public_policy
  to   = aws_ecrpublic_repository_polic.generate_sbom_trivy_db
}

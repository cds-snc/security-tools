resource "aws_ecrpublic_repository" "generate_sbom_public" {
  provider        = aws.us-east-1
  repository_name = "${var.product_name}/generate_sbom/trivy"
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
resource "aws_ecrpublic_repository_policy" "sbom_public_policy" {
  provider        = aws.us-east-1
  repository_name = aws_ecrpublic_repository.generate_sbom_public.repository_name
  policy          = sensitive(data.aws_iam_policy_document.sbom_public_policy_document.json)
}

locals {
  trivy_db_download = "trivy-db-download"
}

module "github_workflow_roles" {
  source            = "github.com/cds-snc/terraform-modules//gh_oidc_role?ref=v10.11.0"
  billing_tag_value = var.billing_tag_value
  roles = [
    {
      name      = local.trivy_db_download
      repo_name = "*" # Allow any CDS repo to use this role
      claim     = "ref:refs/heads/main"
    }
  ]
}

#
# Allow GitHub workflows in CDS repos to download the Trivy database
#
resource "aws_iam_role_policy_attachment" "trivy_db_download" {
  role       = local.trivy_db_download
  policy_arn = aws_iam_policy.trivy_db_download.arn
  depends_on = [
    module.github_workflow_roles
  ]
}

resource "aws_iam_policy" "trivy_db_download" {
  name   = local.trivy_db_download
  policy = data.aws_iam_policy_document.trivy_db_download.json
}

data "aws_iam_policy_document" "trivy_db_download" {
  statement {
    sid = "ECRPublicAuth"
    actions = [
      "ecr-public:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
    ]
    resources = ["*"]
  }
}

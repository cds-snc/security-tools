###
# Container Execution Role
###
# Role that the Amazon ECS container agent and the Docker daemon can assume
###

resource "aws_iam_role" "sso_proxy_container_execution_role" {
  name               = "sso_proxy_container_execution_role"
  assume_role_policy = data.aws_iam_policy_document.sso_proxy_container_execution_role.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_iam_role_policy_attachment" "ce_cs" {
  role       = aws_iam_role.sso_proxy_container_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

###
# Policy Documents
###

data "aws_iam_policy_document" "sso_proxy_container_execution_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sso_proxy_container_policies" {
  role       = aws_iam_role.sso_proxy_container_execution_role.name
  policy_arn = aws_iam_policy.sso_proxy_container_policies.arn
}

data "aws_iam_policy_document" "sso_proxy_container_policies" {
  statement {

    effect = "Allow"

    actions = [
      "ssm:GetParameters",
    ]
    resources = [
      aws_ssm_parameter.google_client_id.arn,
      aws_ssm_parameter.google_client_secret.arn,
      aws_ssm_parameter.oauth2_proxy_cookie_secret.arn,
    ]
  }
}

resource "aws_iam_policy" "sso_proxy_container_policies" {
  name   = "SSOProxyContainerExecutionPolicies"
  path   = "/"
  policy = data.aws_iam_policy_document.sso_proxy_container_policies.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

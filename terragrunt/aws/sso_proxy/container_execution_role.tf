###
# Container Execution Role
###
# Role that the Amazon ECS container agent and the Docker daemon can assume
###

resource "aws_iam_role" "pomerium_container_execution_role" {
  name               = "pomerium_container_execution_role"
  assume_role_policy = data.aws_iam_policy_document.pomerium_container_execution_role.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_iam_role_policy_attachment" "ce_cs" {
  role       = aws_iam_role.pomerium_container_execution_role.name
  policy_arn = data.aws_iam_policy.ec2_container_service.arn
}

###
# Policy Documents
###

data "aws_iam_policy_document" "pomerium_container_execution_role" {
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

data "aws_iam_policy" "ec2_container_service" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "pomerium_policies" {
  role       = aws_iam_role.pomerium_container_execution_role.name
  policy_arn = aws_iam_policy.pomerium_policies.arn
}

data "aws_iam_policy_document" "pomerium_policies" {
  statement {

    effect = "Allow"

    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameters",
    ]
    resources = [
      aws_ssm_parameter.pomerium_google_client_id.arn,
      aws_ssm_parameter.pomerium_google_client_secret.arn,
      aws_ssm_parameter.session_key.arn,
      aws_ssm_parameter.session_cookie_secret.arn,
      aws_ssm_parameter.pomerium_client_id.arn,
      aws_ssm_parameter.pomerium_client_secret.arn,
    ]
  }
}

resource "aws_iam_policy" "pomerium_policies" {
  name   = "PomeriumSSOContainerExecutionPolicies"
  path   = "/"
  policy = data.aws_iam_policy_document.pomerium_policies.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

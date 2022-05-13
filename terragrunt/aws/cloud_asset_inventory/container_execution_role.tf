###
# Container Execution Role
###
# Role that the Amazon ECS container agent and the Docker daemon can assume
###

resource "aws_iam_role" "cartography_container_execution_role" {
  name               = "cartography_container_execution_role"
  assume_role_policy = data.aws_iam_policy_document.cartography_container_execution_role.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_iam_role_policy_attachment" "ce_cs" {
  role       = aws_iam_role.cartography_container_execution_role.name
  policy_arn = data.aws_iam_policy.ec2_container_service.arn
}

###
# Policy Documents
###

data "aws_iam_policy_document" "cartography_container_execution_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
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

resource "aws_iam_role_policy_attachment" "cartography_policies" {
  role       = aws_iam_role.cartography_container_execution_role.name
  policy_arn = aws_iam_policy.cartography_policies.arn
}

data "aws_iam_policy_document" "cartography_policies" {
  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]
    resources = local.trusted_role_arns
  }

  statement {

    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [
      "*"
    ]
  }

  statement {

    effect = "Allow"

    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameters",
    ]
    resources = [
      aws_ssm_parameter.neo4j_auth.arn,
      aws_ssm_parameter.neo4j_password.arn,
      aws_ssm_parameter.asset_inventory_account_list.arn,
    ]
  }
}

resource "aws_iam_policy" "cartography_policies" {
  name   = "CartographyContainerExecutionPolicies"
  path   = "/"
  policy = data.aws_iam_policy_document.cartography_policies.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

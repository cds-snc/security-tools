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
    Product               = "${var.product_name}-${var.tool_name}"
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
      identifiers = ["ecs.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
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

data "aws_iam_policy_document" "cartography_global_read_only" {
  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:Describe*",
    ]
    resources = [
      "*"
    ]
  }

  statement {

    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [
      "*"
    ]
  }

}

data "aws_iam_policy_document" "cartography_constrained" {

  statement {

    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
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
      aws_ssm_parameter.customer_id.arn,
      aws_ssm_parameter.shared_key.arn,
    ]
  }

  statement {

    effect = "Allow"

    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:DescribeFileSystemPolicy",
      "elasticfilesystem:DescribeFileSystems",
    ]
    resources = [
      aws_efs_file_system.neo4j.arn,
    ]
  }

  statement {

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.cartography.arn}:*",
      "${aws_cloudwatch_log_group.neo4j.arn}:*",
    ]
  }

  statement {

    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.cartography_container_execution_role.arn,
      aws_iam_role.cartography_task_execution_role.arn,
    ]
  }
}


data "aws_iam_policy_document" "cartography_policies" {
  source_policy_documents = [
    data.aws_iam_policy_document.cartography_global_read_only.json,
    data.aws_iam_policy_document.cartography_constrained.json,
  ]
}

resource "aws_iam_policy" "cartography_policies" {
  name   = "CartographyContainerExecutionPolicies"
  path   = "/"
  policy = data.aws_iam_policy_document.cartography_policies.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

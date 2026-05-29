locals {
  cartography_service_name = "cartography"
}

data "template_file" "cartography_container_definition" {
  template = file("container-definitions/cartography.json.tmpl")

  vars = {
    AWS_LOGS_GROUP           = aws_cloudwatch_log_group.cartography.name
    AWS_LOGS_REGION          = var.region
    AWS_LOGS_STREAM_PREFIX   = "${local.cartography_service_name}-task"
    CARTOGRAPHY_IMAGE        = "${var.cartography_image}:${var.cartography_image_tag}"
    CARTOGRAPHY_SERVICE_NAME = local.cartography_service_name
    NEO4J_SECRETS_PASSWORD   = aws_ssm_parameter.neo4j_password.arn
  }
}

resource "aws_ecs_task_definition" "cartography" {
  family                   = local.cartography_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 4096
  memory = 8192

  execution_role_arn = aws_iam_role.cartography_container_execution_role.arn
  task_role_arn      = aws_iam_role.cartography_task_execution_role.arn

  container_definitions = data.template_file.cartography_container_definition.rendered

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_cloudwatch_log_group" "cartography" {
  name              = "/aws/ecs/${local.cartography_service_name}"
  retention_in_days = 14

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}



# CloudWatch Event Rule to trigger Cartography ECS task directly
resource "aws_cloudwatch_event_rule" "asset_inventory_cartography" {
  name                = "cartography"
  schedule_expression = "cron(0 22 * * ? *)"
  state               = "ENABLED"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_cloudwatch_event_target" "cartography_ecs" {
  rule     = aws_cloudwatch_event_rule.asset_inventory_cartography.name
  arn      = aws_ecs_cluster.cloud_asset_discovery.arn
  role_arn = aws_iam_role.cartography_events.arn
  ecs_target {
    task_count          = 1
    launch_type         = "FARGATE"
    task_definition_arn = aws_ecs_task_definition.cartography.arn
    network_configuration {
      subnets          = var.vpc_private_subnet_ids
      security_groups  = [aws_security_group.cartography.id]
      assign_public_ip = false
    }
    # Optionally override command/args here if needed
    # overrides = jsonencode({
    #   containerOverrides = [{
    #     name = local.cartography_service_name
    #     command = [
    #       "cartography",
    #       "--neo4j-uri", "bolt://neo4j.internal.local:7687",
    #       "--neo4j-user", "neo4j",
    #       "--neo4j-password-env-var", "NEO4J_SECRETS_PASSWORD",
    #       "--aws-sync-all-profiles",
    #       "--aws-best-effort-mode"
    #     ]
    #   }]
    # })
  }
}

resource "aws_iam_role" "cartography_events" {
  name = "cartographyEventsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_iam_role_policy" "cartography_events" {
  name = "cartographyEventsPolicy"
  role = aws_iam_role.cartography_events.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "iam:PassRole"
        ]
        Resource = [
          aws_ecs_task_definition.cartography.arn,
          aws_iam_role.cartography_task_execution_role.arn,
          aws_iam_role.cartography_container_execution_role.arn
        ]
      }
    ]
  })
}

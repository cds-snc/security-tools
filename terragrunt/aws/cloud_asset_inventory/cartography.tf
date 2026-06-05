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

    # The init container's discovery logic is a standalone boto3 script
    # (generate_config.py) that runs in the cartography image (no extra image).
    GENERATE_CONFIG_SCRIPT_B64 = base64encode(file("container-definitions/generate_config.py"))
    ORG_LIST_ROLE_ARN          = local.organization_account_list_role_arn
    MGMT_ACCOUNT_ID            = var.organization_management_account_id
    SPOKE_ROLE_NAME            = var.cartography_spoke_role_name
    REGION                     = var.region
    NEO4J_BOLT_URI             = "bolt://${aws_lb.cartography.dns_name}:7687"
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

  # Ephemeral volume shared between the init container (writes the generated AWS
  # config) and the cartography container (reads it). Lives for the task lifetime.
  volume {
    name = "cartography-config"
  }

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




# EventBridge Scheduler to trigger Cartography ECS task directly
resource "aws_scheduler_schedule" "cartography" {
  name       = "cartography-schedule"
  group_name = null
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = "cron(0 22 * * ? *)"
  target {
    arn      = aws_ecs_cluster.cloud_asset_discovery.arn
    role_arn = aws_iam_role.cartography_events.arn
    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.cartography.arn
      launch_type         = "FARGATE"
      task_count          = 1
      network_configuration {
        subnets          = var.vpc_private_subnet_ids
        security_groups  = [aws_security_group.cartography.id]
        assign_public_ip = false
      }
    }
  }
}

resource "aws_iam_role" "cartography_events" {
  name = "cartographyEventsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
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

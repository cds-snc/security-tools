locals {
  csp_reports_service_name = "csp_reports"
}

resource "aws_ecs_service" "csp_reports" {
  name                              = local.csp_reports_service_name
  cluster                           = aws_ecs_cluster.csp_reports.id
  task_definition                   = aws_ecs_task_definition.csp_reports.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 600

  load_balancer {
    target_group_arn = aws_lb_target_group.csp_reports.arn
    container_name   = local.csp_reports_service_name
    container_port   = 8000
  }

  network_configuration {
    security_groups = [aws_security_group.csp_reports.id, module.csp_reports_db.proxy_security_group_id]
    subnets         = var.vpc_private_subnet_ids
  }
}

data "template_file" "csp_reports_container_definition" {
  template = file("container-definitions/csp_reports.json.tmpl")

  vars = {
    AWS_LOGS_GROUP         = aws_cloudwatch_log_group.csp_reports.name
    AWS_LOGS_REGION        = var.region
    AWS_LOGS_STREAM_PREFIX = "${local.csp_reports_service_name}-task"
    IMAGE                  = "${aws_ecr_repository.csp_reports.repository_url}:latest"
    SERVICE_NAME           = local.csp_reports_service_name
    DB_HOST                = aws_ssm_parameter.db_host.arn
    DB_USERNAME            = aws_ssm_parameter.db_username.arn
    DB_DATABASE            = aws_ssm_parameter.db_database.arn
    DB_PASSWORD            = aws_ssm_parameter.db_password.arn
  }
}

resource "aws_ecs_task_definition" "csp_reports" {
  family                   = local.csp_reports_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 2048
  memory = 8192

  execution_role_arn = aws_iam_role.csp_reports_container_execution_role.arn
  task_role_arn      = aws_iam_role.csp_reports_task_execution_role.arn

  container_definitions = data.template_file.csp_reports_container_definition.rendered

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_cloudwatch_log_group" "csp_reports" {
  name              = "/aws/ecs/${local.csp_reports_service_name}"
  retention_in_days = 14

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

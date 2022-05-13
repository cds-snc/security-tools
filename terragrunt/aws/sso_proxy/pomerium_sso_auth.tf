locals {
  pomerium_sso_proxy_auth_service_name = "pomerium_sso_proxy_auth"
}

resource "aws_ecs_service" "pomerium_sso_proxy_auth" {
  name            = local.pomerium_sso_proxy_auth_service_name
  cluster         = aws_ecs_cluster.sso_proxy.id
  task_definition = aws_ecs_task_definition.pomerium_sso_proxy_auth.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  service_registries {
    registry_arn = aws_service_discovery_service.auth.arn
  }

  network_configuration {
    security_groups = [aws_security_group.pomerium.id]
    subnets         = var.vpc_private_subnet_ids
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

data "template_file" "pomerium_sso_proxy_auth_container_definition" {
  template = file("container-definitions/pomerium_sso_proxy_auth.json.tmpl")

  vars = {
    AWS_LOGS_GROUP                = aws_cloudwatch_log_group.pomerium_sso_proxy_auth.name
    AWS_LOGS_REGION               = var.region
    AWS_LOGS_STREAM_PREFIX        = "${local.pomerium_sso_proxy_auth_service_name}-task"
    POMERIUM_CLIENT_ID            = aws_ssm_parameter.pomerium_client_id.arn
    POMERIUM_CLIENT_SECRET        = aws_ssm_parameter.pomerium_client_secret.arn
    POMERIUM_GOOGLE_CLIENT_ID     = aws_ssm_parameter.pomerium_google_client_id.arn
    POMERIUM_GOOGLE_CLIENT_SECRET = aws_ssm_parameter.pomerium_google_client_secret.arn
    POMERIUM_VERIFY_IMAGE         = "${var.pomerium_verify_image}:${var.pomerium_verify_image_tag}"
  }
}

resource "aws_ecs_task_definition" "pomerium_sso_proxy_auth" {
  family                   = local.pomerium_sso_proxy_auth_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 1024
  memory = 2048

  execution_role_arn = aws_iam_role.pomerium_container_execution_role.arn
  task_role_arn      = aws_iam_role.pomerium_task_execution_role.arn

  container_definitions = data.template_file.pomerium_sso_proxy_auth_container_definition.rendered

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_cloudwatch_log_group" "pomerium_sso_proxy_auth" {
  name              = "/aws/ecs/${local.pomerium_sso_proxy_auth_service_name}"
  retention_in_days = 14

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

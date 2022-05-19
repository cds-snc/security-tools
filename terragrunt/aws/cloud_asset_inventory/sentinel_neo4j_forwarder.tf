locals {
  elasticsearch_config_file             = "configs/es-index.json"
  sentinel_neo4j_forwarder_service_name = "sentinel_neo4j_forwarder"
}

data "template_file" "sentinel_neo4j_forwarder_container_definition" {
  template = file("container-definitions/sentinel_neo4j_forwarder.json.tmpl")

  vars = {
    AWS_LOGS_GROUP                 = aws_cloudwatch_log_group.sentinel_neo4j_forwarder.name
    AWS_LOGS_REGION                = var.region
    AWS_LOGS_STREAM_PREFIX         = "${local.sentinel_neo4j_forwarder_service_name}-task"
    SENTINEL_NEO4J_FORWARDER_IMAGE = "${aws_ecr_repository.sentinel_neo4j_forwarder.repository_url}:latest"
    CUSTOMER_ID                    = var.customer_id
    LOG_TYPE                       = "CartographyTest"
    SHARED_KEY                     = var.shared_key
    NEO4J_URI                      = "bolt://neo4j.internal.local:7687"
    NEO4J_USER                     = "neo4j"
    NEO4J_SECRETS_PASSWORD         = aws_ssm_parameter.neo4j_password.value
  }
}

resource "aws_ecs_task_definition" "sentinel_neo4j_forwarder" {
  family                   = local.sentinel_neo4j_forwarder_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 2048
  memory = 4096

  execution_role_arn = aws_iam_role.cartography_container_execution_role.arn
  task_role_arn      = aws_iam_role.cartography_task_execution_role.arn

  container_definitions = data.template_file.sentinel_neo4j_forwarder_container_definition.rendered

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }

  volume {
    name = "elasticsearch-index-volume"
  }
}

resource "aws_cloudwatch_log_group" "sentinel_neo4j_forwarder" {
  name              = "/aws/ecs/${local.sentinel_neo4j_forwarder_service_name}"
  retention_in_days = 14

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}
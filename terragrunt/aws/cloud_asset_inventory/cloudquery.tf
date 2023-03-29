locals {
  cloudquery_service_name = "cloudquery"
}

data "template_file" "cloudquery_container_definition" {
  template = file("container-definitions/cloudquery.json.tmpl")

  vars = {
    AWS_LOGS_GROUP          = aws_cloudwatch_log_group.cloudquery.name
    AWS_LOGS_REGION         = var.region
    AWS_LOGS_STREAM_PREFIX  = "${local.cloudquery_service_name}-task"
    CLOUDQUERY_IMAGE        = "${aws_ecr_repository.cloudquery.repository_url}:latest"
    CLOUDQUERY_SERVICE_NAME = local.cloudquery_service_name
    CQ_S3_BUCKET            = "${module.cloudquery_s3_bucket.s3_bucket_id}"
  }
}

resource "aws_ecs_task_definition" "cloudquery" {
  family                   = local.cloudquery_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 4096
  memory = 8192

  execution_role_arn = aws_iam_role.cloudquery_container_execution_role.arn
  task_role_arn      = aws_iam_role.cloudquery_task_execution_role.arn

  container_definitions = data.template_file.cloudquery_container_definition.rendered

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }

}

resource "aws_cloudwatch_log_group" "cloudquery" {
  name              = "/aws/ecs/${local.cloudquery_service_name}"
  retention_in_days = 14

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

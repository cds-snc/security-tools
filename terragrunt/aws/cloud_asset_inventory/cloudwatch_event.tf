# Create the resources required to execute an ECS Task for aws_ecs_task_definition.cloudquery

resource "aws_cloudwatch_event_rule" "cloudquery" {
  name                = "cloudquery"
  description         = "CloudQuery ECS Task"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "cloudquery" {
    rule      = aws_cloudwatch_event_rule.cloudquery.name
    target_id = "cloudquery"
    arn       = aws_ecs_cluster.cloud_asset_discovery.arn
    role_arn  = aws_iam_role.cloudquery_container_execution_role.arn
    
    ecs_target {
        task_count          = 1
        task_definition_arn = aws_ecs_task_definition.cloudquery.arn
        launch_type         = "FARGATE"
        network_configuration {
        subnets          = var.vpc_private_subnet_ids
        security_groups  = [aws_security_group.cloudquery.id]
        assign_public_ip = true
        }
    }
}
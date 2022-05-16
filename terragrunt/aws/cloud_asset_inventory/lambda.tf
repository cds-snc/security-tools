#
# Lambda: zip
#
data "archive_file" "neo4j_to_sentinel" {
  type        = "zip"
  source_dir  = "${path.module}/src/sentinel_ingestor/dist"
  output_path = "/tmp/neo4j_to_sentinel.py.zip"
}

resource "aws_lambda_function" "neo4j_to_sentinel" {
  filename      = data.archive_file.neo4j_to_sentinel.output_path
  function_name = "sentinel-neo4j-forwarder"
  handler       = "neo4j_to_sentinel.handler"
  runtime       = "python3.9"
  timeout       = 300
  memory_size   = 256
  role          = aws_iam_role.neo4j_to_sentinel_lambda.arn

  source_code_hash = data.archive_file.neo4j_to_sentinel.output_base64sha256

  vpc_config {
    subnet_ids         = var.vpc_private_subnet_ids
    security_group_ids = [aws_security_group.cartography.id]
  }

  environment {
    variables = {
      CUSTOMER_ID            = var.customer_id
      LOG_TYPE               = "CartographyTest"
      SHARED_KEY             = var.shared_key
      NEO4J_URI              = "bolt://neo4j.internal.local:7687"
      NEO4J_USER             = "neo4j"
      NEO4J_SECRETS_PASSWORD = aws_ssm_parameter.neo4j_password.value
    }
  }

  tracing_config {
    mode = "Active"
  }

  layers = ["arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:6"]

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "null_resource" "lambda_build" {
  triggers = {
    handler       = base64sha256(file("src/sentinel_ingestor/neo4j_to_sentinel.py"))
    connector     = base64sha256(file("src/sentinel_ingestor/neo4j_connector.py"))
    requirements  = base64sha256(file("src/sentinel_ingestor/requirements.txt"))
    neo4j_queries = base64sha256(file("src/sentinel_ingestor/queries.json"))
    build         = base64sha256(file("src/sentinel_ingestor/build.sh"))
  }

  provisioner "local-exec" {
    command = "${path.module}/src/sentinel_ingestor/build.sh"
  }
}

resource "aws_cloudwatch_log_group" "neo4j_to_sentinel" {
  name              = "/aws/lambda/sentinel-neo4j-forwarder"
  retention_in_days = "14"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

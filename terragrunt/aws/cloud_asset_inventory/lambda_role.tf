#
# IAM
#

resource "aws_iam_role" "neo4j_to_sentinel_lambda" {
  name               = "Neo4JLambdaSentinelIngestor"
  assume_role_policy = data.aws_iam_policy_document.neo4j_to_sentinel_lambda_assume.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_iam_role_policy_attachment" "neo4j_to_sentinel_lambda_basic_execution" {
  role       = aws_iam_role.neo4j_to_sentinel_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "neo4j_to_sentinel_lambda_vpc_service_role" {
  role       = aws_iam_role.neo4j_to_sentinel_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "neo4j_to_sentinel_lambda_xray_write" {
  role       = aws_iam_role.neo4j_to_sentinel_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

data "aws_iam_policy_document" "neo4j_to_sentinel_lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

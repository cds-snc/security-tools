data "aws_iam_policy_document" "purge_csp_reports_lambda_policies" {

  statement {

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:ca-central-1:${var.account_id}:log-group:*"
    ]
  }

  statement {

    effect = "Allow"

    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      aws_ssm_parameter.db_host.arn,
      aws_ssm_parameter.db_username.arn,
      aws_ssm_parameter.db_database.arn,
      aws_ssm_parameter.db_password.arn
    ]
  }
}

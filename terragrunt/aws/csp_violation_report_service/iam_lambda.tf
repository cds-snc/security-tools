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
      "lambda:InvokeFunction"
    ]
    resources = [
      module.purge_csp_reports_lambda.function_arn
    ]
  }
}

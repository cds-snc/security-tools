output "csp_reports_function_url" {
  description = "The URL of the CSP report Lambda function"
  value       = aws_lambda_function_url.csp_reports.function_url
}
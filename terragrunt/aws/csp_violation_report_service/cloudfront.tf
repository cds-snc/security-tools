resource "aws_cloudfront_distribution" "csp_reports" {
  enabled     = true
  aliases     = [var.tool_domain_name]
  price_class = "PriceClass_100"
  web_acl_id  = aws_wafv2_web_acl.csp_report.arn

  origin {
    domain_name = split("/", aws_lambda_function_url.csp_reports.function_url)[2]
    origin_id   = aws_lambda_function_url.csp_reports.function_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_read_timeout    = 60
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id       = aws_lambda_function_url.csp_reports.function_name
    viewer_protocol_policy = "redirect-to-https"

    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03" # SecurityHeadersPolicy https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
    origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html

    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.csp_reports.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = {
    CostCentre = var.tool_name
    Terraform  = true
  }
}

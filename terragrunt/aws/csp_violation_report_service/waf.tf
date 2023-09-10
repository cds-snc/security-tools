resource "aws_wafv2_web_acl" "csp_report" {
  provider = aws.us-east-1

  name        = "csp_report"
  description = "WAF for CSP report service"
  scope       = "CLOUDFRONT"

  tags = {
    CostCentre = var.billing_tag_value
    Terraform  = true
  }

  default_action {
    allow {}
  }

  rule {
    name     = "InvalidRequest"
    priority = 10

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          and_statement {
            statement {
              byte_match_statement {
                search_string = "post"
                field_to_match {
                  method {}
                }
                text_transformation {
                  priority = 1
                  type     = "COMPRESS_WHITE_SPACE"
                }
                text_transformation {
                  priority = 2
                  type     = "LOWERCASE"
                }
              }
            }
            statement {
              regex_pattern_set_reference_statement {
                arn = aws_wafv2_regex_pattern_set.valid_uri_paths.arn
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 1
                  type     = "COMPRESS_WHITE_SPACE"
                }
                text_transformation {
                  priority = 2
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "InvalidPaths"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimit"
    priority = 20

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 500
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 40

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "csp_report"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_regex_pattern_set" "valid_uri_paths" {
  provider    = aws.us-east-1
  name        = "ValidURIPaths"
  description = "Regex to match the CSP report valid URI paths"
  scope       = "CLOUDFRONT"

  regular_expression {
    regex_string = "^/report$"
  }

  tags = {
    CostCentre = var.billing_tag_value
    Terraform  = true
  }
}

# terraform/waf.tf

resource "aws_wafv2_ip_set" "website_allowed_ips" {
  provider = aws.us-east-1

  name               = "website-allowed-ips"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.allowed_ips

  tags = {
    "jt:my-personal-system:name"        = "website-allowed-ips"
    "jt:my-personal-system:description" = "IP set for personal access to the website"
    "jt:my-personal-system:module"      = "security"
  }
}

resource "aws_wafv2_ip_set" "api_allowed_ips" {
  provider = aws.us-east-1

  name               = "api-allowed-ips"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.allowed_ips

  tags = {
    "jt:my-personal-system:name"        = "api-allowed-ips"
    "jt:my-personal-system:description" = "IP set for personal access to the REST API"
    "jt:my-personal-system:module"      = "security"
  }
}

resource "aws_wafv2_web_acl" "website_waf" {
  name        = "websit_waf"
  description = "Website Web Application Firewall"
  scope       = "CLOUDFRONT"

  default_action {
    block {
      custom_response {
        response_code = 403
        custom_response_body_key = "custom-blocked-response"
      }
    }
  }

  custom_response_body {
    key          = "custom-blocked-response"
    content_type = "APPLICATION_JSON"
    content      = jsonencode({
      "error" : "Forbidden",
      "message" : "Access from this IP address is not allowed."
    })
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "website-waf"
    sampled_requests_enabled   = false
  }

  rule {
    name = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 0
    override_action {
        none {}
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesAmazonIpReputationList"
        vendor_name =  "AWS"
      }
    }
    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "AWS-AWSManagedRulesAmazonIpReputationList"
        sampled_requests_enabled = true
    }
  }

  rule {
    name = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
        none {}
    }
    statement {
        managed_rule_group_statement {
            name = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"
        }
    }
    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "AWS-AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled = true
    }
  }

  rule {
      name = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      priority = 2
      override_action {
          none {}
      }
      statement {
          managed_rule_group_statement {
              name = "AWSManagedRulesKnownBadInputsRuleSet"
              vendor_name = "AWS"
          }
      }
      visibility_config {
          cloudwatch_metrics_enabled = true
          metric_name = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
          sampled_requests_enabled = true
      }
  }

  rule {
      name = "website-waf-allowed-ips-rule"
      priority = 3
      action {
          allow {}
      }
      statement {
          ip_set_reference_statement {
              arn = aws_wafv2_ip_set.website_allowed_ips.arn
          }
      }
      visibility_config {
          cloudwatch_metrics_enabled = true
          metric_name = "website-waf-allowed-ips-rule"
          sampled_requests_enabled = true
      }
  }

  tags = {
    "jt:my-personal-system:name" = "website-waf"
    "jt:my-personal-system:description" = "Website Web Application Firewall"
    "jt:my-personal-system:module" = "waf"
    "jt:my-personal-system:component" = "cloud-front-distribution"
  }
}

resource "aws_wafv2_web_acl" "api_waf" {
  name        = "api-waf"
  description = "REST API Web Application Firewall"
  scope       = "REGIONAL"

  default_action {
    block {
      custom_response {
        response_code = 403
        custom_response_body_key = "custom-blocked-response"
      }
    }
  }

  custom_response_body {
    key          = "custom-blocked-response"
    content_type = "APPLICATION_JSON"
    content      = jsonencode({
      "error" : "Forbidden",
      "message" : "Access from this IP address is not allowed."
    })
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "api-waf"
    sampled_requests_enabled   = false
  }

  rule {
    name = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 0
    override_action {
        none {}
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesAmazonIpReputationList"
        vendor_name =  "AWS"
      }
    }
    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "AWS-AWSManagedRulesAmazonIpReputationList"
        sampled_requests_enabled = true
    }
  }

  rule {
    name = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
        none {}
    }
    statement {
        managed_rule_group_statement {
            name = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"
        }
    }
    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "AWS-AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled = true
    }
  }

  rule {
      name = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      priority = 2
      override_action {
          none {}
      }
      statement {
          managed_rule_group_statement {
              name = "AWSManagedRulesKnownBadInputsRuleSet"
              vendor_name = "AWS"
          }
      }
      visibility_config {
          cloudwatch_metrics_enabled = true
          metric_name = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
          sampled_requests_enabled = true
      }
  }

  rule {
      name = "api-waf-allowed-ips-rule"
      priority = 3
      action {
          allow {}
      }
      statement {
          ip_set_reference_statement {
              arn = aws_wafv2_ip_set.api_allowed_ips.arn
          }
      }
      visibility_config {
          cloudwatch_metrics_enabled = true
          metric_name = "api-waf-allowed-ips-rule"
          sampled_requests_enabled = true
      }
  }

  tags = {
    "jt:my-personal-system:name" = "api-waf"
    "jt:my-personal-system:description" = "REST API Web Application Firewall"
    "jt:my-personal-system:module" = "waf"
    "jt:my-personal-system:component" = "cloud-front-distribution"
  }
}

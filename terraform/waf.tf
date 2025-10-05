# terraform/waf.tf

resource "aws_wafv2_ip_set" "allowed_ips" {
  provider = aws.us-east-1

  name               = "personal-system-allowed-ips"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.allowed_ips

  tags = {
    "jt:my-personal-system:name"        = "waf-allowed-ips"
    "jt:my-personal-system:description" = "IP set for personal access to the website and API"
    "jt:my-personal-system:module"      = "security"
  }
}

resource "aws_wafv2_web_acl" "my_personal_system_waf" {
  name        = "my-personal-system-waf"
  description = "Web Application Firewall"
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
    metric_name                = "my-personal-system-waf"
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
      name = "my-personal-system-allowed-ips-rule"
      priority = 3
      action {
          allow {}
      }
      statement {
          ip_set_reference_statement {
              arn = aws_wafv2_ip_set.allowed_ips.arn
          }
      }
      visibility_config {
          cloudwatch_metrics_enabled = true
          metric_name = "my-personal-system-allowed-ips-rule"
          sampled_requests_enabled = true
      }
  }

  tags = {
    "jt:my-personal-system:name" = "my-personal-system-waf"
    "jt:my-personal-system:description" = "Web Application Firewall"
    "jt:my-personal-system:module" = "waf"
    "jt:my-personal-system:component" = "cloud-front-distribution"
  }
}

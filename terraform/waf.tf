# terraform/waf.tf

# 1. Creates a set of the IP addresses you want to allow
resource "aws_wafv2_ip_set" "allowed_ips" {
  provider = aws.us-east-1 # WAF for CloudFront must be in us-east-1

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

# 2. Creates the Web ACL (the firewall rule)
resource "aws_wafv2_web_acl" "main" {
  provider = aws.us-east-1 # WAF for CloudFront must be in us-east-1

  name  = "personal-system-acl"
  scope = "CLOUDFRONT"

  # The default action is to block any request that doesn't match a rule
  default_action {
    block {}
  }

  # Add a rule to allow requests from your IP set
  rule {
    name     = "Allow-Personal-IPs"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowed_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "Allow-Personal-IPs"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "personal-system-acl"
    sampled_requests_enabled   = false
  }

  tags = {
    "jt:my-personal-system:name"        = "waf-main-acl"
    "jt:my-personal-system:description" = "Main WAF ACL to restrict access to CloudFront distributions"
    "jt:my-personal-system:module"      = "security"
  }
}
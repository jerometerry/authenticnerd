resource "aws_s3_bucket" "authentic_nerd_blog_s3_bucket" {
  bucket = "authentic-nerd-blog"

  tags = {
    "jt:authentic-nerd:name"        = "authentic-nerd-blog"
    "jt:authentic-nerd:description" = "S3 Bucket for hosting blog static assets"
    "jt:authentic-nerd:module"      = "frontend"
    "jt:authentic-nerd:component"   = "authentic-nerd-blog"
  }
}

resource "aws_s3_bucket_versioning" "authentic_nerd_blog_s3_bucket_versioning" {
  bucket = aws_s3_bucket.authentic_nerd_blog_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "authentic_nerd_blog_s3_bucket_access_block" {
  bucket = aws_s3_bucket.authentic_nerd_blog_s3_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_function" "dir_index_rewrite" {
  name    = "astro-dir-index-rewrite"
  runtime = "cloudfront-js-2.0"
  comment = "Rewrite subdirectories to index.html for Astro static builds"
  publish = true
  code    = file("${path.module}/rewrite.js")
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "authentic-nerd-security-policy-v1"
  comment = "Security headers for A+ rating on SecurityHeaders.com"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000 # 1 Year
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    content_security_policy {
      content_security_policy = "default-src 'none'; script-src 'self' 'unsafe-inline'; connect-src 'self'; img-src 'self'; style-src 'self' 'unsafe-inline'; manifest-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; frame-src 'self' https://www.youtube-nocookie.com https://www.youtube.com;"
      override                = true
    }
  }

  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      value    = "camera=(), microphone=(), geolocation=(), payment=(), usb=(), xr-spatial-tracking=()"
      override = true
    }
  }

  remove_headers_config {
    items {
      header = "Server"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "blog_oac" {
  name                              = "blog_oac"
  description                       = "Origin Access Control for the blog S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "blog_cloudformation_distribution" {
  enabled             = true
  http_version        = "http3"
  default_root_object = "index.html"
  aliases = [
    "${var.blog_subdomain_name}.${var.domain_name}",
    var.domain_name,
    "www.${var.domain_name}"
  ]
  web_acl_id  = aws_wafv2_web_acl.blog_waf.arn
  price_class = "PriceClass_100"

  custom_error_response {
    error_code            = 403
    response_page_path    = "/404.html"
    response_code         = 404
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_page_path    = "/404.html"
    response_code         = 404
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 500
    response_page_path    = "/404.html"
    response_code         = 404
    error_caching_min_ttl = 10
  }

  origin {
    domain_name              = aws_s3_bucket.authentic_nerd_blog_s3_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.authentic_nerd_blog_s3_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.blog_oac.id
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.blog_cert_validation.certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.authentic_nerd_blog_s3_bucket.id
    compress         = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.dir_index_rewrite.arn
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.authentic_nerd_blog_system_logs_s3_bucket.bucket_domain_name
    prefix          = "cloudfront/"
  }

  tags = {
    Name                            = "blog-cloudfront-distribution"
    "jt:authentic-nerd:name"        = "blog-cloudfront-distribution"
    "jt:authentic-nerd:description" = "Public access to the blog"
    "jt:authentic-nerd:module"      = "blog"
    "jt:authentic-nerd:component"   = "cloud-front-distribution"
  }
}

resource "aws_s3_bucket_policy" "authentic_nerd_blog_s3_bucket_policy" {
  bucket = aws_s3_bucket.authentic_nerd_blog_s3_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "s3:GetObject",
      Effect = "Allow",
      Principal = {
        Service = "cloudfront.amazonaws.com"
      },
      Resource = "${aws_s3_bucket.authentic_nerd_blog_s3_bucket.arn}/*",
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.blog_cloudformation_distribution.arn
        }
      }
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.authentic_nerd_blog_s3_bucket_access_block]
}

resource "aws_wafv2_web_acl" "blog_waf" {
  name        = "blog_waf"
  description = "Blog Web Application Firewall"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  custom_response_body {
    key          = "custom-blocked-response"
    content_type = "APPLICATION_JSON"
    content = jsonencode({
      "error" : "Forbidden",
      "message" : "Access from this IP address is not allowed."
    })
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "blog-waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "Block-PHP-Files"
    priority = 0
    action {
      block {}
    }
    statement {
      byte_match_statement {
        search_string         = ".php"
        positional_constraint = "ENDS_WITH"
        field_to_match {
          uri_path {}
        }
        text_transformation {
          priority = 0
          type     = "LOWERCASE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Block-PHP-Files"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "Block-WordPress-Paths"
    priority = 1
    action {
      block {}
    }
    statement {
      regex_match_statement {
        regex_string = "/wp-(admin|content|includes|login)"
        field_to_match {
          uri_path {}
        }
        text_transformation {
          priority = 0
          type     = "LOWERCASE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Block-WordPress-Paths"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "Block-Dotfiles"
    priority = 2
    action {
      block {}
    }
    statement {
      and_statement {
        statement {
          regex_match_statement {
            regex_string = "/\\.[a-zA-Z0-9]+"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
        statement {
          not_statement {
            statement {
              byte_match_statement {
                search_string         = "/.well-known"
                positional_constraint = "STARTS_WITH"
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Block-Dotfiles"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 3
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
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 4
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 5
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
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    "jt:authentic-nerd:name"        = "blog-waf"
    "jt:authentic-nerd:description" = "Blog Web Application Firewall"
    "jt:authentic-nerd:module"      = "waf"
    "jt:authentic-nerd:component"   = "cloud-front-distribution"
  }
}

resource "aws_s3_bucket" "authentic_nerd_blog_system_logs_s3_bucket" {
  bucket        = "authentic-nerd-blog-system-logs"
  force_destroy = true

  tags = {
    "jt:authentic-nerd:name"        = "authentic-nerd-blog-system-logs-s3-bucket"
    "jt:authentic-nerd:description" = "S3 Bucket for hosting blog system logs"
    "jt:authentic-nerd:module"      = "frontend"
    "jt:authentic-nerd:component"   = "authentic-nerd-blog-system-logs-s3-bucket"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "authentic_nerd_blog_system_logs_s3_bucket_lifecycle_configuration" {
  bucket = aws_s3_bucket.authentic_nerd_blog_system_logs_s3_bucket.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "authentic_nerd_blog_system_logs_s3_bucket_ownership_controls" {
  bucket = aws_s3_bucket.authentic_nerd_blog_system_logs_s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "authentic_nerd_blog_system_logs_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.authentic_nerd_blog_system_logs_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "authentic_nerd_blog_system_logs_s3_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.authentic_nerd_blog_system_logs_s3_bucket_ownership_controls, aws_s3_bucket_public_access_block.authentic_nerd_blog_system_logs_s3_bucket_public_access_block]
  bucket     = aws_s3_bucket.authentic_nerd_blog_system_logs_s3_bucket.id
  acl        = "private"
}


data "aws_iam_policy_document" "authentic_nerd_blog_cloudfront_logs_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalLogDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["${aws_s3_bucket.authentic_nerd_blog_system_logs_s3_bucket.arn}/cloudfront/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.blog_cloudformation_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "authentic_nerd_blog_system_logs_s3_bucket_policy" {
  bucket = aws_s3_bucket.authentic_nerd_blog_system_logs_s3_bucket.id
  policy = data.aws_iam_policy_document.authentic_nerd_blog_cloudfront_logs_policy.json
}

resource "aws_cloudwatch_dashboard" "waf_dashboard" {
  dashboard_name = "Blog-WAF-Metrics"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/WAFV2", "AllowedRequests", "WebACL", "blog_waf", "Rule", "ALL"],
            [".", "BlockedRequests", ".", ".", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          stat    = "Sum"
          period  = 300
          title   = "Total Edge Traffic"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/WAFV2", "BlockedRequests", "WebACL", "blog_waf", "Rule", "Block-WordPress-Paths"],
            [".", ".", ".", ".", ".", "Block-PHP-Files"],
            [".", ".", ".", ".", ".", "Block-Dotfiles"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          stat    = "Sum"
          period  = 300
          title   = "Custom Edge Blocks"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/WAFV2", "BlockedRequests", "WebACL", "blog_waf", "Rule", "AWS-AWSManagedRulesAmazonIpReputationList"],
            [".", ".", ".", ".", ".", "AWS-AWSManagedRulesKnownBadInputsRuleSet"],
            [".", ".", ".", ".", ".", "AWS-AWSManagedRulesCommonRuleSet"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          stat    = "Sum"
          period  = 300
          title   = "AWS Managed Rule Blocks"
        }
      }
    ]
  })
}

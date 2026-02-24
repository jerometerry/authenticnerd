resource "aws_s3_bucket" "logs" {
  bucket        = var.blog_system_logs_s3_bucket_name
  force_destroy = true

  tags = {
    "jt:my-personal-system:name"        = "blog-system-logs-s3-bucket"
    "jt:my-personal-system:description" = "S3 Bucket for hosting blog system logs"
    "jt:my-personal-system:module"      = "frontend"
    "jt:my-personal-system:component"   = "blog-system-logs-s3-bucket"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_cleanup" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "logs_security" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "logs" {
  depends_on = [aws_s3_bucket_ownership_controls.logs, aws_s3_bucket_public_access_block.logs_security]
  bucket     = aws_s3_bucket.logs.id
  acl        = "private"
}

data "aws_iam_policy_document" "cloudfront_logs_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalLogDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["${aws_s3_bucket.logs.arn}/cloudfront/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.blog_cloudformation_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.cloudfront_logs_policy.json
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

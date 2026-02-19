resource "aws_cognito_identity_pool" "web_rum_pool" {
  identity_pool_name               = "web-rum-pool"
  allow_unauthenticated_identities = true
}

resource "aws_iam_role" "web_rum_guest_role" {
  name = "WebRumGuestRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Condition = {
          "StringEquals" = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.web_rum_pool.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })
}

resource "aws_cognito_identity_pool_roles_attachment" "web_rum_attachment" {
  identity_pool_id = aws_cognito_identity_pool.web_rum_pool.id
  roles = {
    "unauthenticated" = aws_iam_role.web_rum_guest_role.arn
  }
}

resource "aws_rum_app_monitor" "blog_monitor" {
  name             = "blog-rum"
  domain           = var.domain_name
  cw_log_enabled   = true
  
  app_monitor_configuration {
    allow_cookies       = true
    enable_xray         = true
    session_sample_rate = 1.0
    telemetries         = ["performance", "errors", "http"]

    guest_role_arn = aws_iam_role.web_rum_guest_role.arn
    identity_pool_id = aws_cognito_identity_pool.web_rum_pool.id
  }
}

resource "aws_iam_role_policy" "blog_rum_send_policy" {
  name = "BlogRumSendPolicy"
  role = aws_iam_role.web_rum_guest_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "rum:PutRumEvents"
        Resource = aws_rum_app_monitor.blog_monitor.arn
      }
    ]
  })
}

resource "aws_s3_bucket" "logs" {
  bucket = var.blog_system_logs_s3_bucket_name
  force_destroy = true

  tags = {
    "jt:my-personal-system:name" = "blog-system-logs-s3-bucket"
    "jt:my-personal-system:description" = "S3 Bucket for hosting blog system logs"
    "jt:my-personal-system:module" = "frontend"
    "jt:my-personal-system:component" = "blog-system-logs-s3-bucket"
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
  depends_on = [aws_s3_bucket_ownership_controls.logs]
  bucket     = aws_s3_bucket.logs.id
  acl        = "private"
}

resource "aws_s3_bucket" "blog_s3_bucket" {
  bucket = var.blog_s3_bucket_name
  
  tags = {
    "jt:my-personal-system:name" = "blog-s3-bucket"
    "jt:my-personal-system:description" = "S3 Bucket for hosting blog static assets"
    "jt:my-personal-system:module" = "frontend"
    "jt:my-personal-system:component" = "blog-s3-bucket"
  }
}

resource "aws_s3_bucket_versioning" "blog_versioning" {
  bucket = aws_s3_bucket.blog_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "blog_access_block" {
  bucket = aws_s3_bucket.blog_s3_bucket.id
  
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
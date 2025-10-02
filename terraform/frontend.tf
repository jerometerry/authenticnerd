# terraform/frontend.tf

# 1. S3 bucket to store the static files
resource "aws_s3_bucket" "site_bucket" {
  bucket = "my-personal-system-unique-bucket-name"
}

resource "aws_s3_bucket_website_configuration" "site_config" {
  bucket = aws_s3_bucket.site_bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "site_access_block" {
  bucket = aws_s3_bucket.site_bucket.id

  # Keep these two `true` as we are not using ACLs
  block_public_acls       = true
  ignore_public_acls      = true

  # Set these two to `false` to allow a public website policy
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "s3:GetObject",
      Effect    = "Allow",
      Principal = "*",
      Resource  = "${aws_s3_bucket.site_bucket.arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.site_access_block]
}

# 2. CloudFront distribution (CDN)
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.site_bucket.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.site_bucket.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# 3. Output the website URL
output "website_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

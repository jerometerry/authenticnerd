# terraform/frontend.tf

# 1. S3 bucket to store the static files (now private)
resource "aws_s3_bucket" "site_bucket" {
  bucket = "my-personal-system-unique-bucket-name" # <-- MAKE SURE THIS MATCHES YOUR EXISTING BUCKET NAME
}

# 2. Block ALL public access to the S3 bucket
# This is more secure than the previous configuration.
resource "aws_s3_bucket_public_access_block" "site_access_block" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# 3. Create the CloudFront Origin Access Control (OAC)
# This is the modern replacement for the older Origin Access Identity (OAI).
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-for-personal-system"
  description                       = "Origin Access Control for the personal system S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 4. CloudFront distribution (CDN)
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.site_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"] # OPTIONS is often needed for CORS
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

# 5. A new, secure bucket policy
# This policy GRANTS access ONLY to the CloudFront distribution.
resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "s3:GetObject",
      Effect    = "Allow",
      Principal = {
        Service = "cloudfront.amazonaws.com"
      },
      Resource  = "${aws_s3_bucket.site_bucket.arn}/*",
      Condition = {
        StringEquals = {
          # This condition ensures only YOUR CloudFront distribution can access the files.
          "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
        }
      }
    }]
  })

  # Ensure the bucket is private BEFORE applying this policy.
  depends_on = [aws_s3_bucket_public_access_block.site_access_block]
}


# 6. Output the website URL (this remains the same)
output "website_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}
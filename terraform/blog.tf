# terraform/blog.tf

resource "aws_s3_bucket" "blog_s3_bucket" {
  bucket = var.blog_s3_bucket_name
  
  tags = {
    "jt:my-personal-system:name" = "blog-s3-bucket"
    "jt:my-personal-system:description" = "S3 Bucket for hosting blog static assets"
    "jt:my-personal-system:module" = "frontend"
    "jt:my-personal-system:component" = "blog-s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "blog_access_block" {
  bucket = aws_s3_bucket.blog_s3_bucket.id
  
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

resource "aws_cloudfront_distribution" "blog_cloudformation_distribution" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = ["${var.blog_subdomain_name}.${var.domain_name}"]
  web_acl_id          = aws_wafv2_web_acl.blog_waf.arn
  price_class         = "PriceClass_100"

  custom_error_response {
    error_code            = 404
    response_page_path    = "/404.html"
    response_code         = 404
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 500
    response_page_path    = "/500.html"
    response_code         = 500
    error_caching_min_ttl = 300
  }

  origin {
    domain_name              = aws_s3_bucket.blog_s3_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.blog_s3_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.website_oac.id
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
    target_origin_id = aws_s3_bucket.blog_s3_bucket.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.dir_index_rewrite.arn
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "index.html"
    target_origin_id = aws_s3_bucket.blog_s3_bucket.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    cache_policy_id  = data.aws_cloudfront_cache_policy.caching_disabled.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.no_cache_headers.id
  }

  tags = {
    Name = "blog-cloudfront-distribution"
    "jt:my-personal-system:name" = "blog-cloudfront-distribution"
    "jt:my-personal-system:description" = "Public access to the blog"
    "jt:my-personal-system:module" = "blog"
    "jt:my-personal-system:component" = "cloud-front-distribution"
  }
}

resource "aws_s3_bucket_policy" "blog_s3_bucket_policy" {
  bucket = aws_s3_bucket.blog_s3_bucket.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "s3:GetObject",
      Effect    = "Allow",
      Principal = {
        Service = "cloudfront.amazonaws.com"
      },
      Resource  = "${aws_s3_bucket.blog_s3_bucket.arn}/*",
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.blog_cloudformation_distribution.arn
        }
      }
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.blog_access_block]
}
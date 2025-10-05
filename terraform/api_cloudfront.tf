# terraform/api_cloudfront.tf

# 1. Create an Origin Request Policy to forward the Host header
resource "aws_cloudfront_origin_request_policy" "api_policy" {
  name    = "api-gateway-host-header"
  comment = "Policy to forward Host header to API Gateway"
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Host"]
    }
  }
  cookies_config {
    cookie_behavior = "none"
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}

# 2. Create the CloudFront distribution for the API
resource "aws_cloudfront_distribution" "api_distribution" {
  enabled             = true
  default_root_object = "" # APIs don't have a root object
  aliases             = ["${var.api_subdomain_name}.${var.domain_name}"]
  price_class = "PriceClass_100"
  
  origin {
    # The domain_name is the invoke URL from your REST API, without the stage
    domain_name = "${aws_api_gateway_rest_api.rest_api_gateway.id}.execute-api.us-east-1.amazonaws.com"
    origin_id   = "api-gateway-origin"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "api-gateway-origin"
    
    # Use the new Origin Request Policy
    origin_request_policy_id = aws_cloudfront_origin_request_policy.api_policy.id

    # For an API, you typically want to disable caching and forward all values
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    # Use a managed policy that's optimized for caching API responses
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingOptimized
  }

  # Attach the WAF Web ACL
  web_acl_id = aws_wafv2_web_acl.my_personal_system_waf.arn

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.api_cert_validation.certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    "jt:my-personal-system:name"        = "api-distribution"
    "jt:my-personal-system:description" = "Public access to the API via CloudFront"
    "jt:my-personal-system:module"      = "backend"
    "jt:my-personal-system:component"   = "cloud-front-distribution"
  }
}

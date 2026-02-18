# terraform/dns.tf

data "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_acm_certificate" "site_cert" {
  provider          = aws.us-east-1
  domain_name       = var.tools_portal_subdomain
  validation_method = "DNS"

  tags = {
    Name = "my-personal-system-site-cert"
    "jt:my-personal-system:name" = "site-cert"
    "jt:my-personal-system:description" = "Website Cert"
    "jt:my-personal-system:module" = "dns"
    "jt:my-personal-system:component" = "cloud-front-distribution"
  }
}

resource "aws_route53_record" "site_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "site_cert_validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.site_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.site_cert_validation : record.fqdn]
}

resource "aws_route53_record" "site_dns" {
  name    = aws_acm_certificate.site_cert.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id
  alias {
    name                   = aws_cloudfront_distribution.website_cloudformation_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_cloudformation_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "api_cert" {
  provider          = aws.us-east-1
  domain_name       = "${var.api_subdomain_name}.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "my-personal-system-api-cert"
    "jt:my-personal-system:name" = "api-cert"
    "jt:my-personal-system:description" = "REST API Cert"
    "jt:my-personal-system:module" = "dns"
    "jt:my-personal-system:component" = "cloud-front-distribution"
  }
}

resource "aws_route53_record" "api_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "api_cert_validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.api_cert_validation : record.fqdn]
}

resource "aws_route53_record" "api_dns" {
  name    = aws_acm_certificate.api_cert.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id
  alias {
    name                   = aws_api_gateway_domain_name.api_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api_domain.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "blog_cert" {
  provider          = aws.us-east-1
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "www.${var.domain_name}",
    "${var.blog_subdomain_name}.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "my-personal-system-blog-cert"
    "jt:my-personal-system:name" = "blog-cert"
    "jt:my-personal-system:description" = "Blog Cert"
    "jt:my-personal-system:module" = "dns"
    "jt:my-personal-system:component" = "cloud-front-distribution"
  }
}

resource "aws_route53_record" "blog_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.blog_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "blog_cert_validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.blog_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.blog_cert_validation : record.fqdn]
}

resource "aws_route53_record" "blog_dns" {
  name    = "${var.blog_subdomain_name}.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id

  alias {
    name                   = aws_cloudfront_distribution.blog_cloudformation_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.blog_cloudformation_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root_dns" {
  name    = var.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id

  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.blog_cloudformation_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.blog_cloudformation_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_dns" {
  name    = "www.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id

  alias {
    name                   = aws_cloudfront_distribution.blog_cloudformation_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.blog_cloudformation_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "google_verification" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 300
  
  records = [
    "google-site-verification=HqHEsNeSFE-0oVhnrA_ilIAIW-Dvo20QKu0xTzQClNY"
  ]
}
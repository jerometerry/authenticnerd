# terraform/dns.tf

data "aws_route53_zone" "main" {
  name = var.domain_name
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
# terraform/dns.tf

resource "aws_acm_certificate" "site_cert" {
  provider = aws.us-east-1

  domain_name       = "${var.subdomain_name}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    "jt:my-personal-system:name" = "website-ssl-cert"
    "jt:my-personal-system:description" = "SSL Cert for Website"
    "jt:my-personal-system:module" = "dns"
    "jt:my-personal-system:component" = "cloud-front-distribution"
  }
}

# This resource tells Terraform to wait until the certificate is validated
# before trying to use it. The validation itself is a manual step for you.
resource "aws_acm_certificate_validation" "site_cert_validation" {
  provider = aws.us-east-1
  certificate_arn         = aws_acm_certificate.site_cert.arn
}
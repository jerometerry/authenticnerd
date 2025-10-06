# terraform/api_domain.tf

# 1. Creates the custom domain name for the REST API
resource "aws_api_gateway_domain_name" "api_domain" {
  domain_name     = "${var.api_subdomain_name}.${var.domain_name}"
  certificate_arn = aws_acm_certificate_validation.api_cert_validation.certificate_arn
  endpoint_configuration {
    types = ["EDGE"]
  }

  tags = {
    "jt:my-personal-system:name"        = "api-custom-domain"
    "jt:my-personal-system:description" = "Custom domain for the REST API"
    "jt:my-personal-system:module"      = "backend"
    "jt:my-personal-system:component"   = "api-gateway"
  }
}

# 2. Maps the custom domain to our specific REST API and stage (v1)
resource "aws_api_gateway_base_path_mapping" "api_mapping" {
  domain_name = aws_api_gateway_domain_name.api_domain.domain_name
  api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
}
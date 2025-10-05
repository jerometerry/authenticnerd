# terraform/outputs.tf

output "apigateway_endpoint_url" {
  description = "The invoke URL for the API Gateway."
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}

output "website_url" {
  description = "The URL for the CloudFront distribution."
  value       = "https://${aws_cloudfront_distribution.website_cloudformation_distribution.domain_name}"
}

output "website_s3_bucket_name" {
  description = "The name of the S3 bucket for the frontend."
  value       = aws_s3_bucket.website_s3_bucket.id
}

output "website_cloudformation_distribution" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.website_cloudformation_distribution.id
}

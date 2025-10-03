# terraform/outputs.tf

output "api_endpoint_url" {
  description = "The invoke URL for the API Gateway."
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}

output "website_url" {
  description = "The URL for the CloudFront distribution."
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for the frontend."
  value       = aws_s3_bucket.site_bucket.id
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.id
}

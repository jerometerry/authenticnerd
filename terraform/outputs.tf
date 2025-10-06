# terraform/outputs.tf

output "website_s3_bucket_name" {
  description = "The name of the S3 bucket for the frontend."
  value       = aws_s3_bucket.website_s3_bucket.id
}

output "website_cloudformation_distribution" {
  description = "The ID of the website CloudFront distribution."
  value       = aws_cloudfront_distribution.website_cloudformation_distribution.id
}

output "website_cloudfront_url" {
  description = "The URL of the website CloudFront distribution."
  value       = "https://${aws_cloudfront_distribution.website_cloudformation_distribution.domain_name}"
}

output "api_lambda_invoke_arn" {
  description = "The invoke ARN for the API Lambda"
  value       = aws_lambda_function.api_lambda.invoke_arn
}

output "rest_apigateway_endpoint_url" {
  description = "The invoke URL for the REST API Gateway."
  value       = aws_api_gateway_stage.api_stage.invoke_url
}

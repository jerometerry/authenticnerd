# terraform/outputs.tf

output "blog_s3_bucket_name" {
  description = "The name of the S3 bucket for the blog."
  value       = aws_s3_bucket.blog_s3_bucket.id
}

output "blog_cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution for the blog."
  value       = aws_cloudfront_distribution.blog_cloudformation_distribution.id
}
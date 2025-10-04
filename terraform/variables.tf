# terraform/variables.tf
variable "s3_bucket_name" {
  description = "The unique name for the S3 bucket."
  type        = string
  default     = "my-personal-system-unique-bucket-name"
}

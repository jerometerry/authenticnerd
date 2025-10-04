# terraform/variables.tf
variable "s3_bucket_name" {
  description = "The unique name for the S3 bucket."
  type        = string
  default     = "my-personal-system-unique-bucket-name"
}

variable "atlas_public_key" {
  description = "MongoDB Atlas Public API Key."
  type        = string
  sensitive   = true
}

variable "atlas_private_key" {
  description = "MongoDB Atlas Private API Key."
  type        = string
  sensitive   = true
}
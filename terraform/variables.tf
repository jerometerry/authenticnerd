# terraform/variables.tf

variable "domain_name" {
  description = "The root domain name you have registered"
  type        = string
}

variable "blog_subdomain_name" {
  description = "The subdomain for the blog"
  type        = string
}

variable "blog_s3_bucket_name" {
  description = "Name of the S3 bucket for hosting the blog's static assets."
  type        = string
}

variable "blog_system_logs_s3_bucket_name" {
  description = "Name of the S3 bucket for hosting the blog's system logs."
  type        = string
}
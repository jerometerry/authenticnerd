# terraform/variables.tf
variable "website_s3_bucket_name" {
  description = "Name of the S3 bucket for hosting static assets"
  type        = string
  default     = "my-personal-system-website"
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

variable "atlas_connection_string" {
  description = "Connection string for the MongoDB Atlas cluster."
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "The root domain name you have registered"
  type        = string
}

variable "website_subdomain_name" {
  description = "The subdomain for your website"
  type        = string
}

variable "api_subdomain_name" {
  description = "The subdomain for your API"
  type        = string
}

variable "allowed_ips" {
  description = "The subdomain for your API"
  type        = list(string)
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
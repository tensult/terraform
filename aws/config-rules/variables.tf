variable "profile" {
  description = "AWS Profile"
  default     = "default"
}

variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "config_bucket_name" {
  description = "AWS Config S3 Bucket name"
}

variable "account_name" {
  description = "AWS Account Name"
}

variable "ses_email" {
  description = "SES verified email"
}

variable "admin_email" {
  description = "Admin email"
}

variable "notification_emails" {
  description = "Email to be notified"
  type        = "string"
  default     = ""
}

variable "company_name" {
  description = "Name of the company"
}

variable "profile" {
  description = "AWS Profile"
  default     = "default"
}

variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
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

variable "send_to_admin" {
  description = "Email to be notified"
  type        = "string"
  default     = "yes"
}

variable "stop_instances" {
  description = "Instances to be stopped"
  type        = "string"
  default     = "yes"
}

variable "company_name" {
  description = "Name of the company"
}

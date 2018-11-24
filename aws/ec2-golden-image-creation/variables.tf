variable "profile" {
  description = "AWS Profile"
  default     = "default"
}

variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "account_ids" {
  description = "Account IDs to share newly created image"
  type        = "list"
  default     = []
}

variable "profile" {
  description = "AWS Profile"
  default     = "default"
}

variable "requester_account_id" {
  description = "Account ID of AWS account which gets the permission to the role"
  default     = "default"
}
variable "profile" {
  description = "AWS Profile"
  default     = "default"
}
variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "EC2 AMI Id"
}

variable "account_ids" {
  description = "List of Account IDs"
  type = "list"
}
variable "profile" {
  description = "AWS Profile"
  default     = "default"
}
variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "domain_name" {
  description = "Domain name"
}

variable "domain_dns_ip" {
  description = "Domain DNS IP"
}

variable "domain_username" {
  description = "Domain username"
}

variable "domain_password" {
  description = "Domain password"
}
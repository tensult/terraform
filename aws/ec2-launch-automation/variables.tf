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

variable "domain_ou_path" {
  description = "Domain OU path"
}

variable "domain_dns_ips" {
  description = "Domain DNS IPs"
  type        = "list"
}

variable "amazon_dns" {
  description = "Amazon Provided DNS"
  default     = ["AmazonProvidedDNS"]
  type        = "list"
}

variable "domain_username" {
  description = "Domain username"
}

variable "domain_password" {
  description = "Domain password"
}

variable "sudoers" {
  description = "sudoers group for linux instances"
}

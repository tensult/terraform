#Define Region
variable "profile" {
  description = "AWS Profile"
  default     = "default"
}
variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
}

variable "sub_public_1a" {
  description = "CIDR for the public subnet"
}

variable "sub_public_1b" {
  description = "CIDR for the public subnet"
}

variable "sub_private_1a" {
  description = "CIDR for the private subnet"
}

variable "sub_private_1b" {
  description = "CIDR for the private subnet"
}

#Customet Gateway
variable "customer_gw" {
  description = "Define customer Gateway"
}

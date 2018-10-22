variable "aws_region" {
    description = "Region for the VPC"
    default = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR for the Shared Service VPC"
  default = "10.13.0.0/20"
}

variable "sub_public_1a" {
  description = "CIDR for the public subnet"
  default = "10.13.2.0/24"
}

variable "sub_public_1b" {
  description = "CIDR for the public subnet"
  default = "10.13.3.0/24"
}

variable "sub_private_1a" {
  description = "CIDR for the private subnet"
  default = "10.13.0.0/24"
}

variable "sub_private_1b" {
  description = "CIDR for the private subnet"
  default = "10.13.1.0/24"
}
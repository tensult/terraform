variable "region" {
  description = "AWS region to create VPC"
  default     = "ap-south-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  default     = "three-tier"
}

variable "public_subnets_cidr_blocks" {
  description = "CIRD blocks of subnets in web layer"
  default     = ["10.0.5.0/24", "10.0.7.0/24"]
}

variable "web_subnets_cidr_blocks" {
  description = "CIRD blocks of subnets in web layer"
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "app_subnets_cidr_blocks" {
  description = "CIRD blocks of subnets in app layer"
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "db_subnets_cidr_blocks" {
  description = "CIRD blocks of subnets in DB layer"
  default     = ["10.0.6.0/24", "10.0.8.0/24"]
}
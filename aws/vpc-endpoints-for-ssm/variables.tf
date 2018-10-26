variable "profile" {
  description = "AWS Profile"
  default     = "default"
}
variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "AWS VPC ID"
}

variable "subnet_cidrs" {
  description = "AWS Subnet CIDR ranges"
  type = "list"
  default = []
}
variable "owner_profile" {
  description = "AWS Profile"
  default     = "default"
}
variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "accepter_profile" {
  description = "AWS Profile"
  default     = "default"
}

variable "owner_vpc_id" {
  description = "Owner VPC Id"
}

variable "accepter_vpc_id" {
  description = "Accepter VPC Id"
}
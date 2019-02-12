#Define Region
variable "profile" {
  description = "AWS Profile"
  default     = "default"
}
variable "region" {
  description = "AWS region"
  default     = "default"
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

variable "sb_sshArch_1a" {
  description = "CIDR"
}

variable "sb_sshArch_1b" {
  description = "CIDR"
}

variable "sb_rds_1a" {
  description = "CIDR"
}

variable "sb_rds_1b" {
  description = "CIDR"
}

variable "sb_iopted_1a" {
  description = "CIDR"
}

variable "sb_iopted_1b" {
  description = "CIDR"
}



# #Customet Gateway
# variable "customer_gw" {
#   description = "Define customer Gateway"
# }

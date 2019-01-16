variable "profile" {
  description = "AWS Profile"
  default = "default"
}

variable "region" {
  description = "AWS Region"
  default = "ap-south-1"
}

variable "vpc_id" {
  description = "AWS VPC id"
}

variable "sub_private_1a" {
  description = "Subnet Range"
}

variable "sub_private_1b" {
  description = "Subnet Range"
}

variable "sub_public_1a" {
  description = "Subnet Range"
}

variable "sub_public_1b" {
  description = "Subnet Range"
}

variable "customer" {
  description = "Name of the Customer"
}

variable "customer_cidr_block" {
  description = "CIDR Block of Customer"
}

variable "customer_gw" {
  description = "IP of the Customer Gateway"
}

variable "bastion_ip" {
  description = "IP Address of the Bastion Host"
}

variable "sg_bastion" {
  description = "Bastion Host Security Group ID"
}

variable "instance_ami" {
  description = "Instance AMI"
}

variable "dbuser" {
  description = "Username of RDS user"
}

variable "dbpasswd" {
  description = "Password for dbuser"
}

variable "kms_key" {
  description = "arn of kms key"
}






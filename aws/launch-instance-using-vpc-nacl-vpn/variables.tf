variable "profile" {
  description = "AWS Profile"
  default = "default"
}

variable "region" {
  description = "AWS Region"
  default = "ap-south-1"
}

################################
variable "vpc_id" {
  description = "AWS VPC id"
}

variable "sub_private_1a" {
  description = "Define Subnet Range"
}

variable "sub_private_1b" {
  description = "Define Subnet Range"
}

variable "sub_public_1a" {
  description = "Subnet Range"
}

variable "sub_public_1b" {
  description = "Subnet Range"
}

################################
variable "customer" {
  description = "Name of the Customer"
}

variable "customer_cidr_block" {
  description = "CIDR Block of Customer"
}

variable "customer_gw" {
  description = "IP of the Customer Gateway"
}

################################
variable "bastion_ip" {
  description = "IP Address of the Bastion Host"
}

variable "sg_bastion" {
  description = "Bastion Host Security Group ID"
}

################################
variable "instance_ami" {
  description = "Instance AMI"
}

################################
# RDS
variable "rds_storage" {
  description = "Storage of the Rds instance"
}

variable "rds_engine" {
  description = "Engine of the RDS Instance"
}

variable "engine_version" {
  description = "Engine Verstion"
}

variable "rds_instanceclass" {
  description = "RDS instance Class type"
}

variable "rds_identifier" {
  description = "identification of the RDS"
}

variable "rds_name" {
  description = "Name of the RDS instance"
}

variable "rds_username" {
  description = "Username of the RDS"
}

variable "rds_password" {
  description = "Password of the RDS instance"
}

variable "db_pg_family" {
  description = "Family of the parameter Group"
}

################################################
#load Balancer


# variable "name" {
#   description = ""
# }



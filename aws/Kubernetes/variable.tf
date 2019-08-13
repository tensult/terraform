variable "profile" {
  description = "AWS User account Profile"
}

variable "region" {
  default = "ap-south-1"
}

variable "key" {
  description = "Enter Key name"
}

variable "sub_ids" {
  default = []
}

variable "instance-ami" {
  default = "ami-0b99c7725b9484f9e" # AMI of Mumbai region
}

variable "instance_type" {
  default = "t3.medium"
}


variable "cluster-name" {
  description = "Cluster Name"
}

variable "server-name" {
  description = "Ec2 Server Name"
}

variable "vpc_name" {
  description = "VPC name"
}

variable "master_subnet_cidr" {
  default = []
  description = "Master Node Cidr Range"
}

variable "worker_subnet_cidr" {
  default = []
  description = "Worker node cidr range"
}

variable "public_subnet_cidr" {
  default = []
  description = "Public Subnet cidr range"
}

variable "private_subnet_cidr" {
  default = []
  description = "Private Subnet CIDR range"
}
variable "cidr" {
  default = ""
  description = "VPC Cidr Range"
}




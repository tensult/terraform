#
# Variables Configuration
#
variable "cluster-name" {}

variable "vpc_id" {
  description = "VPC ID "
}

variable "eks_subnets" {
  description = "Master subnet ids"
  type        = "list"
}

variable "worker_subnet" {
  type = "list"
}

variable "subnet_ids" {
  type        = "list"
  description = "List of all subnet in cluster"
}

variable "kubernetes-server-instance-sg" {
  description = "Kubenetes control server security group"
}

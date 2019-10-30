variable "alb_name" {
  description = "Define ALB Name"
}

variable "env" {
  description = "Define Enviourment name eg - Production"
}

variable "profile" {}

variable "region" {}

variable "vpc_id" {}

variable "subnet_id" {
  type = "list"
}

variable "cer_arn" {
  
}

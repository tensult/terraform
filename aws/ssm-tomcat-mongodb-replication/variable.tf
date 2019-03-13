variable "profile" {
  description = "AWS Profile"
  default = "default"
}

variable "region" {
  description = "AWS Region"
  default = "ap-south-1"
}

variable "customer" {
  description = "Name of the customer"
}

variable "tomcat_file" {
  description = "Tomcat Text file in s3"
}

variable "mongo_file" {
  description = "MongoDB Text file in S3"
}



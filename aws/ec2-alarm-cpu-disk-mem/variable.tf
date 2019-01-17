variable "profile" {
  description = "AWS Profile"
  default = "default"
}

variable "region" {
  description = "AWS Region"
  default = "ap-south-1"
}

variable "instance_id" {
  description = "EC2 instance ID"
}

variable "app_name" {
  description = "Name of the Application"
}

variable "sns_topic" {
  description = "SNS Topic for Sending CloudWatch Alarm Notification"
}




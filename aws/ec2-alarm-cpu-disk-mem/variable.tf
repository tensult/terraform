variable "profile" {
  description = "AWS Profile"
  default = "default"
}

variable "region" {
  description = "AWS Region"
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

variable "ec2_action" {
  description = "EC2 action for Creating Alarm"
}

variable "rds_instance" {
  description = "Name of the RDS Instace"
}

variable "freestoragespace" {
  description = "Define Threshold value of Free Storage Space"
}

variable "freeablememory" {
  description = "Define Threshold value of Freeable­ Memory"
}

variable "load_balancer" {
  description = "Define ARN of the Load Balancer"
}

variable "lb_name" {
  description = "Name of the Load Balancer"
}

variable "alb_targetgroup" {
  description = "ARN of the Load Balancer Target Group"
}









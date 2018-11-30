variable "profile" {
  description = "AWS Profile"
  default     = "default"
}
variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "instance_ids" {
  description = "EC2 instance Ids"
  type = "list"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN"
}
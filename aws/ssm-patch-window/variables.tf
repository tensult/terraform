variable "profile" {
  description = "AWS Profile"
  default     = "default"
}
variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "cutoff_time" {
  description = "Time in hours before end of Patch Maintenance Window when new execution will not be scheduled"
  default = 1
}

variable "duration" {
  description = "Patch Maintenance Window Duration in hours"
  default = 7
}
variable "cron" {
  description = "Cron expression for deciding window scheduling"
  type = "string"
  #The default configured below is cron for running every 2nd Saturday of the month at 10:00 AM
  default = "cron(0 0 10 ? * 7#2)"
 }

 variable "account_id" {
  description = "AccountID"
}

variable "iam_policy_arn" {
  description = "IAM Policy to be used by the maintenance window to execute tasks"
  default = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}
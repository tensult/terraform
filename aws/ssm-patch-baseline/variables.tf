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
  #Please input cron expression in UTC timezone
  default = "cron(0 30 4 ? * 7#2)"
 }

variable "patch_operation"{

  description = "Decide the Patch Operation behaviour. Permitted Values are 'Scan' and 'Install'." 
  default = "Install"
}

variable "log_bucket_name" {
  description ="S3 Bucket where Run Command Execution logs are to be stored"
}


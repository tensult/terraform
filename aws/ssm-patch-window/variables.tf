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
}

variable "duration" {
  description = "Patch Maintenance Window Duration in hours"
  
}
variable "cron" {
  description = "Cron expression for deciding window scheduling"
  
}
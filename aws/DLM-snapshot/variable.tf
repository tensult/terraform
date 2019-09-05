variable "profile" {
  default = "vazid_admin"
}
variable "region" {
  default = "ap-south-1"
}

variable "snapshot_name" {
  description = "2 weeks of daily snapshots"
}

variable "interval_hours" {
  description = "interval to be one of 2 3 4 6 8 12 24"
}

variable "retention_count" {
  description = "Number of snapshot to keep"
}

variable "start_time" {
  description = "Times in 24 hour clock"
}





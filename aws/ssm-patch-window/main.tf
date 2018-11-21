provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}
resource "aws_ssm_maintenance_window" "window" {
  name     = "Patch-maintenance-window"
  schedule = "${var.cron}"
  duration = "${var.duration}"
  cutoff   = "${var.cutoff_time}"
}

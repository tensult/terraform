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

resource "aws_ssm_maintenance_window_target" "target1" {
  window_id     = "${aws_ssm_maintenance_window.window.id}"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:os_type"
    values = ["RedHat6","CentOS6","AmazonLinux2","Ubuntu16"]
  }
}


resource "aws_ssm_maintenance_window_task" "task" {
  window_id        = "${aws_ssm_maintenance_window.window.id}"
  name             = "Run-Patch-Baseline-Document"
  description      = "Task to Install Patches to Linux Instances"
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = "arn:aws:iam::${var.account_id}:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM"
  max_concurrency  = "3"
  max_errors       = "10"

  targets {
    key    = "WindowTargetIds"
    values = ["${aws_ssm_maintenance_window_target.target1.id}"]
  }

  task_parameters {
    name   = "Operation"
    values = ["Install"]
  }
}

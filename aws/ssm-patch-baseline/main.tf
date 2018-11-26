

#This is done for Amazon Linux 2. Depending on OS type, available filters and parameters change
resource "aws_ssm_patch_baseline" "AL2" {
  name             = "patch-baseline-AmazonLinux2"
  description      = "Patch Baseline for AMAZON LINUX 2 Operating System"
  operating_system = "AMAZON_LINUX_2"



  global_filter {
    key    = "CLASSIFICATION"
    values = ["Newpackage"]
  }

  global_filter {
    key    = "SEVERITY"
    values = ["Low","Medium"]
  }

  approval_rule {
    approve_after_days = 7

    patch_filter {
      key    = "PRODUCT"
      values = ["AmazonLinux2"]
    }

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security"]
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical"]
    }
  }

}


#This is done for Ubuntu. Depending on OS type, available filters and parameters change
resource "aws_ssm_patch_baseline" "Ubuntu16" {
  name             = "patch-baseline-Ubuntu"
  description      = "Patch Baseline for Ubuntu Operating System"
  operating_system = "UBUNTU"


  global_filter {
    key    = "PRIORITY"
    values = ["Optional","Extra"]
  }

  approval_rule {
    approve_after_days = 7


    patch_filter {
      key    = "PRIORITY"
      values = ["Required"]
    }
    
  }
 }

#This is done for CentOS. Depending on OS type, available filters and parameters change
 resource "aws_ssm_patch_baseline" "centos" {
  name             = "patch-baseline-CentOS"
  description      = "Patch Baseline for CentOS Operating System"
  operating_system = "CENTOS"


  global_filter {
    key    = "CLASSIFICATION"
    values = ["Newpackage"]
  }

  global_filter {
    key    = "SEVERITY"
    values = ["Low","Moderate"]
  }

  approval_rule {
    approve_after_days = 7
    enable_non_security = true



    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security"]
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical"]
    }
  }

}
#This is done for Redhat. Depending on OS type, available filters and parameters change

resource "aws_ssm_patch_baseline" "Redhat6" {
  name             = "patch-baseline-Redhat"
  description      = "Patch Baseline for Redhat Operating System"
  operating_system = "REDHAT_ENTERPRISE_LINUX"



  global_filter {
    key    = "CLASSIFICATION"
    values = ["Newpackage"]
  }

  global_filter {
    key    = "SEVERITY"
    values = ["Low","Moderate"]
  }

  approval_rule {
    approve_after_days = 7

    
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security"]
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical"]
    }
  }

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
    values = ["RedHat","CentOS","AmazonLinux2","Ubuntu"]
  }
}

resource "aws_iam_service_linked_role" "ssm" {
  aws_service_name = "ssm.amazonaws.com"
  description = "Service Linked Role for Maintenance Windows to execute tasks"
}

resource "aws_ssm_maintenance_window_task" "task" {
  window_id        = "${aws_ssm_maintenance_window.window.id}"
  name             = "Run-Patch-Baseline-Document"
  description      = "Task to Install Patches to Linux Instances"
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = "${aws_iam_service_linked_role.ssm.arn}"
  max_concurrency  = "3"
  max_errors       = "10"

  targets {
    key    = "WindowTargetIds"
    values = ["${aws_ssm_maintenance_window_target.target1.id}"]
  }

  task_parameters {
    name   = "Operation"
    values = ["${var.patch_operation}"]
  }

  logging_info {
    s3_bucket_name = "${var.log_bucket_name}"
    s3_region = "${var.region}"
    s3_bucket_prefix = "${var.profile}/PatchingLogs"
  }
}


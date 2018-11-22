provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"

}

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
  name             = "patch-baseline-Ubuntu16"
  description      = "Patch Baseline for Ubuntu16 Operating System"
  operating_system = "UBUNTU"


  global_filter {
    key    = "PRIORITY"
    values = ["Optional","Extra"]
  }

  approval_rule {
    approve_after_days = 7

    patch_filter {
      key    = "PRODUCT"
      values = ["Ubuntu16.04"]
    }

    patch_filter {
      key    = "PRIORITY"
      values = ["Required"]
    }
    
  }
 }

#This is done for CentOS. Depending on OS type, available filters and parameters change
 resource "aws_ssm_patch_baseline" "centos" {
  name             = "patch-baseline-CentOS6"
  description      = "Patch Baseline for CentOS6 Operating System"
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
      key    = "PRODUCT"
      values = ["CentOS6.5","CentOS6.6","CentOS6.7","CentOS6.8","CentOS6.9"]
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

resource "aws_ssm_patch_baseline" "Redhat6" {
  name             = "patch-baseline-Redhat6"
  description      = "Patch Baseline for Redhat6 Operating System"
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
      key    = "PRODUCT"
      values = ["RedhatEnterpriseLinux6.5","RedhatEnterpriseLinux6.6", "RedhatEnterpriseLinux6.7","RedhatEnterpriseLinux6.8","RedhatEnterpriseLinux6.9"]
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


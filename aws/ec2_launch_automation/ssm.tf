resource "aws_ssm_document" "amazon_linux_automation" {
  name          = "Launch_Automation_for_AmazonLinux"
  document_type = "Automation"

  content = "${file("amazon_linux_launch_automation_document.json")}"
}

resource "aws_ssm_document" "redhat_linux_automation" {
  name          = "Launch_Automation_for_RedHatLinux"
  document_type = "Automation"

  content = "${file("redhat_linux_launch_automation_document.json")}"
}

resource "aws_ssm_document" "centos_linux_automation" {
  name          = "Launch_Automation_for_CentOSLinux"
  document_type = "Automation"

  content = "${file("centos_linux_launch_automation_document.json")}"
}

resource "aws_ssm_document" "ubuntu_linux_automation" {
  name          = "Launch_Automation_for_UbuntuLinux"
  document_type = "Automation"

  content = "${file("ubuntu_linux_launch_automation_document.json")}"
}

resource "aws_ssm_document" "windows2012_linux_automation" {
  name          = "Launch_Automation_for_Windows2012"
  document_type = "Automation"

  content = "${file("windows_2012_launch_automation_document.json")}"
}

resource "aws_ssm_document" "windows2016_linux_automation" {
  name          = "Launch_Automation_for_Windows2016"
  document_type = "Automation"

  content = "${file("windows_2016_launch_automation_document.json")}"
}
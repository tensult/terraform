data "aws_kms_key" "ssm" {
  key_id = "alias/ssm-key"
}

resource "aws_ssm_parameter" "domain_username" {
  name        = "/domain/username"
  description = "Domain username"
  type        = "String"
  value       = "${var.domain_username}"
  overwrite   = true
}

resource "aws_ssm_parameter" "domain_password" {
  name        = "/domain/password"
  description = "Domain password"
  type        = "SecureString"
  value       = "${var.domain_password}"
  key_id      = "${data.aws_kms_key.ssm.arn}"
  overwrite   = true
}

resource "aws_ssm_parameter" "ipdns" {
  name        = "/domain/dns_ip"
  description = "DNS IP Address"
  type        = "String"
  value       = "${join(",", var.domain_dns_ips)}"
  overwrite   = true
}

resource "aws_ssm_parameter" "domain_name" {
  name        = "/domain/name"
  description = "Domain name"
  type        = "String"
  value       = "${var.domain_name}"
  overwrite   = true
}

resource "aws_ssm_parameter" "domain_ou_path" {
  name        = "/domain/ou_path"
  description = "Domain OU path"
  type        = "String"
  value       = "${var.domain_ou_path}"
  overwrite   = true
}

data "template_file" "amazon_linux_automation" {
  # Render the template once for each instance
  template = "${file("amazon_linux_launch_automation_document.json")}"

  vars {
    # count.index tells us the index of the instance we are rendering
    sudoers = "${var.sudoers}"
  }
}

resource "aws_ssm_document" "amazon_linux_automation" {
  name          = "Launch_Automation_for_AmazonLinux"
  document_type = "Automation"

  content = "${data.template_file.amazon_linux_automation.rendered}"
}

data "template_file" "redhat_linux_automation" {
  # Render the template once for each instance
  template = "${file("redhat_linux_launch_automation_document.json")}"

  vars {
    # count.index tells us the index of the instance we are rendering
    sudoers = "${var.sudoers}"
  }
}

resource "aws_ssm_document" "redhat_linux_automation" {
  name          = "Launch_Automation_for_RedHatLinux"
  document_type = "Automation"

  content = "${data.template_file.redhat_linux_automation.rendered}"
}

data "template_file" "centos_linux_automation" {
  # Render the template once for each instance
  template = "${file("centos_linux_launch_automation_document.json")}"

  vars {
    # count.index tells us the index of the instance we are rendering
    sudoers = "${var.sudoers}"
  }
}

resource "aws_ssm_document" "centos_linux_automation" {
  name          = "Launch_Automation_for_CentOSLinux"
  document_type = "Automation"

  content = "${data.template_file.centos_linux_automation.rendered}"
}

data "template_file" "ubuntu_linux_automation" {
  # Render the template once for each instance
  template = "${file("ubuntu_linux_launch_automation_document.json")}"

  vars {
    # count.index tells us the index of the instance we are rendering
    sudoers = "${var.sudoers}"
  }
}

resource "aws_ssm_document" "ubuntu_linux_automation" {
  name          = "Launch_Automation_for_UbuntuLinux"
  document_type = "Automation"

  content = "${data.template_file.ubuntu_linux_automation.rendered}"
}

resource "aws_ssm_document" "windows2012_automation" {
  name          = "Launch_Automation_for_Windows2012"
  document_type = "Automation"

  content = "${file("windows_2012_launch_automation_document.json")}"
}

resource "aws_ssm_document" "windows2016_automation" {
  name          = "Launch_Automation_for_Windows2016"
  document_type = "Automation"

  content = "${file("windows_2016_launch_automation_document.json")}"
}

resource "aws_ssm_document" "ec2_launch_automation" {
  name          = "Launch_Automation_for_Any_OS"
  document_type = "Automation"

  content = "${file("ec2_launch_automation_document.json")}"
}

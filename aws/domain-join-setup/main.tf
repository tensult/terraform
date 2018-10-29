provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}
data "aws_kms_key" "ssm" {
  key_id = "alias/ssm-key"
}

resource "aws_ssm_parameter" "domain_password" {
  name  = "domain/password"
  description  = "Domain password"
  type  = "SecureString"
  value = "${var.domain_password}"
  key_id = "${data.aws_kms_key.ssm.arn}"
}

resource "aws_ssm_parameter" "domain_username" {
  name  = "domain/username"
  description  = "Domain username"
  type  = "SecureString"
  value = "${var.domain_username}"
  key_id = "${data.aws_kms_key.ssm.arn}"
}
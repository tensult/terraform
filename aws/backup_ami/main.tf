provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

resource "aws_ami_from_instance" "ami-backup" {
  name               = "${var.ami_name}"    #Give unique name of AMI
  source_instance_id = "${var.instance_id}" #ID of instance which we are going to take backup
}

provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

resource "aws_ami_launch_permission" "share" {
  count = "${length(var.account_ids)}"
  image_id   = "${var.ami_id}"
  account_id = "${var.account_ids[count.index]}"
}

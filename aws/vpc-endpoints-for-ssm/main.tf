provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

locals {
  default_subnet_cidrs = ["${cidrhost(data.aws_vpc.selected.cidr_block, -128)}/26", "${cidrhost(data.aws_vpc.selected.cidr_block, -64)}/26"]
  selected_subnet_cidrs = "${coalescelist(var.subnet_cidrs, local.default_subnet_cidrs)}"
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnets" {
  count             = "${length(local.selected_subnet_cidrs)}"
  vpc_id            = "${data.aws_vpc.selected.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${local.selected_subnet_cidrs[count.index]}"
  tags {
    Name = "VPC Endpoint"
  }
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "vpc_endpoint"
  description = "Allow VPC traffic to communicate with AWS Services"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.selected.cidr_block}"]
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = "${data.aws_vpc.selected.id}"
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["${aws_subnet.subnets.*.id}"]

  security_group_ids = [
    "${aws_security_group.vpc_endpoint.id}"
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id            = "${data.aws_vpc.selected.id}"
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["${aws_subnet.subnets.*.id}"]

  security_group_ids = [
    "${aws_security_group.vpc_endpoint.id}"
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = "${data.aws_vpc.selected.id}"
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["${aws_subnet.subnets.*.id}"]

  security_group_ids = [
    "${aws_security_group.vpc_endpoint.id}"
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = "${data.aws_vpc.selected.id}"
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["${aws_subnet.subnets.*.id}"]

  security_group_ids = [
    "${aws_security_group.vpc_endpoint.id}"
  ]

  private_dns_enabled = true
}
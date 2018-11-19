provider "aws" {
  profile = "${var.owner_profile}"
  region  = "${var.region}"
}

provider "aws" {
  alias = "accepter"
  region  = "${var.region}"
  profile = "${var.accepter_profile}"
}

data "aws_vpc" "accepter" {
    provider = "aws.accepter"
    id = "${var.accepter_vpc_id}"
}

locals {
  accepter_account_id = "${element(split(":", data.aws_vpc.accepter.arn), 4)}"
}

resource "aws_vpc_peering_connection" "owner" {
  vpc_id = "${var.owner_vpc_id}"
  peer_vpc_id   = "${data.aws_vpc.accepter.id}"
  peer_owner_id = "${local.accepter_account_id}"  

  tags {
    Name = "peer_to_${var.accepter_profile}"
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = "aws.accepter"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.owner.id}"
  auto_accept               = true

  tags {
    Name = "peer_to_${var.owner_profile}"
  }
}

data "aws_vpc" "owner" {
    id = "${var.owner_vpc_id}"
}


data "aws_route_tables" "accepter" {
  provider = "aws.accepter"
  vpc_id = "${data.aws_vpc.accepter.id}"
}

data "aws_route_tables" "owner" {
  vpc_id = "${var.owner_vpc_id}"
}


resource "aws_route" "owner" {
  count = "${length(data.aws_route_tables.owner.ids)}"
  route_table_id            = "${data.aws_route_tables.owner.ids[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.accepter.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.owner.id}"
}   

resource "aws_route" "accepter" {
  provider = "aws.accepter"
  count = "${length(data.aws_route_tables.accepter.ids)}"
  route_table_id            = "${data.aws_route_tables.accepter.ids[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.owner.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.owner.id}"
}  

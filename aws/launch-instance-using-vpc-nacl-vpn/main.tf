# Select an existing VPC

data "aws_vpc" "vpc_client" {
  id = "${var.vpc_id}"
}

# Create public subnets

resource "aws_subnet" "sub_public_1a" {
    vpc_id = "${data.aws_vpc.vpc_client.id}"
    cidr_block = "${var.sub_public_1a}"
    availability_zone = "ap-south-1a"

    tags {
        Name = "sb_${var.customer}_pub_1a"
    }
}

resource "aws_subnet" "sub_public_1b" {
    vpc_id = "${data.aws_vpc.vpc_client.id}"
    cidr_block = "${var.sub_public_1b}"
    availability_zone = "ap-south-1b"

    tags {
        Name = "sb_${var.customer}_pub_1b"
    }
}

# Create private subnets

resource "aws_subnet" "sub_private_1a" {
  vpc_id = "${data.aws_vpc.vpc_client.id}"
  cidr_block = "${var.sub_private_1a}"
  availability_zone = "ap-south-1a"

  tags {
        Name = "sb_${var.customer}_pri_1a"
    }
}

resource "aws_subnet" "sub_private_1b" {
  vpc_id = "${data.aws_vpc.vpc_client.id}"
  cidr_block = "${var.sub_private_1b}"
  availability_zone = "ap-south-1b"

  tags {
        Name = "sb_${var.customer}_pri_1a"
    }
}



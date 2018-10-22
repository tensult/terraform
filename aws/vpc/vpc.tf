# Define our VPC
resource "aws_vpc" "shared" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "vpc_prod"
  }
}
# Define the public subnet
resource "aws_subnet" "sub_pub_1a" {
  vpc_id = "${aws_vpc.shared.id}"
  cidr_block = "${var.sub_public_1a}"
  availability_zone = "ap-south-1a"

  tags {
    Name = "sub_public_1a"
  }
}

# Define the public subnet
resource "aws_subnet" "sub_pub_1b" {
  vpc_id = "${aws_vpc.shared.id}"
  cidr_block = "${var.sub_public_1b}"
  availability_zone = "ap-south-1b"

  tags {
    Name = "sub_public_1b"
  }
}

# Define the private subnet
resource "aws_subnet" "sub_pri_1a" {
  vpc_id = "${aws_vpc.shared.id}"
  cidr_block = "${var.sub_private_1a}"
  availability_zone = "ap-south-1a"

  tags {
    Name = "sub_private_1a"
  }
}

# Define the private subnet
resource "aws_subnet" "sub_pri_1b" {
  vpc_id = "${aws_vpc.shared.id}"
  cidr_block = "${var.sub_private_1b}"
  availability_zone = "ap-south-1b"

  tags {
    Name = "sub_private_1b"
  }
}
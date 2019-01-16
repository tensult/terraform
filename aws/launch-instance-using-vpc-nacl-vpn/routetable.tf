# Define Internet Gateway
data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = ["${data.aws_vpc.vpc_client.id}"]
  }
}

# Create Public Route Tables
resource "aws_route_table" "rt_public" {
  vpc_id = "${data.aws_vpc.vpc_client.id}" 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${data.aws_internet_gateway.igw.id}"
  }
  tags {
      Name = "rt_pub_${var.customer}"
  }
}

# Create Private Route Tables

resource "aws_route_table" "rt_private" {
  vpc_id = "${data.aws_vpc.vpc_client.id}"

  tags {
      Name = "rt_pri_${var.customer}"
  }
}

# associate Route table to public subnet

resource "aws_route_table_association" "public-rt-1" {
  subnet_id      = "${aws_subnet.sub_public_1a.id}"
  route_table_id = "${aws_route_table.rt_public.id}"
}

resource "aws_route_table_association" "public-rt-2" {
    subnet_id = "${aws_subnet.sub_public_1b.id}"
    route_table_id = "${aws_route_table.rt_public.id}"
}


# associate Route table to private subnet

resource "aws_route_table_association" "private-rt-1" {
  subnet_id      = "${aws_subnet.sub_private_1a.id}"
  route_table_id = "${aws_route_table.rt_private.id}"
}

resource "aws_route_table_association" "private-rt-2" {
    subnet_id = "${aws_subnet.sub_private_1b.id}"
    route_table_id = "${aws_route_table.rt_private.id}"
}
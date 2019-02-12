# Define the public route table
resource "aws_route_table" "rt-public-ss" {
    vpc_id = "${aws_vpc.shared.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags {
    Name = "rt_prod_pub"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-rt-1" {
  subnet_id = "${aws_subnet.sub_pub_1a.id}"
  route_table_id = "${aws_route_table.rt-public-ss.id}"
}
# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-rt-2" {
  subnet_id = "${aws_subnet.sub_pub_1b.id}"
  route_table_id = "${aws_route_table.rt-public-ss.id}"
}

resource "aws_route_table_association" "sshArch-1a" {
  subnet_id = "${aws_subnet.sb_sshArch_1a.id}"
  route_table_id = "${aws_route_table.rt-public-ss.id}"
}

resource "aws_route_table_association" "sshArch-1b" {
  subnet_id = "${aws_subnet.sb_sshArch_1b.id}"
  route_table_id = "${aws_route_table.rt-public-ss.id}"
}

resource "aws_route_table_association" "iopted-1a" {
  subnet_id = "${aws_subnet.sb_iopted_1a.id}"
  route_table_id = "${aws_route_table.rt-public-ss.id}"
}

resource "aws_route_table_association" "iopted-1b" {
  subnet_id = "${aws_subnet.sb_iopted_1b.id}"
  route_table_id = "${aws_route_table.rt-public-ss.id}"
}

# Define the private route table
resource "aws_route_table" "rt-private-ss" {
  vpc_id = "${aws_vpc.shared.id}"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat.id}"
  }
  tags {
    Name = "rt_prod_pvt"
  }
}

# Assign the route table to the private Subnet-1
resource "aws_route_table_association" "private-rt-1" {
  subnet_id = "${aws_subnet.sub_pri_1a.id}"
  route_table_id = "${aws_route_table.rt-private-ss.id}"
}
# Assign the route table to the private Subnet-2
resource "aws_route_table_association" "private-rt-2" {
  subnet_id = "${aws_subnet.sub_pri_1b.id}"
  route_table_id = "${aws_route_table.rt-private-ss.id}"
}

resource "aws_route_table_association" "rds_1a" {
  subnet_id = "${aws_subnet.sb_rds_1a.id}"
  route_table_id = "${aws_route_table.rt-private-ss.id}"
}

resource "aws_route_table_association" "rds_1b" {
  subnet_id = "${aws_subnet.sb_rds_1b.id}"
  route_table_id = "${aws_route_table.rt-private-ss.id}"
}

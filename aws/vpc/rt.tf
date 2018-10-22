# Define the public route table
resource "aws_route_table" "rt-public-ss" {
    vpc_id = "${aws_vpc.shared.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags {
    Name = "rt-public"
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

# Define the private route table
resource "aws_route_table" "rt-private-ss" {
  vpc_id = "${aws_vpc.shared.id}"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat.id}"
  }
  tags {
    Name = "rt-private"
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

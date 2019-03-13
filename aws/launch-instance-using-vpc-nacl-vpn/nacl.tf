# Create NACL

resource "aws_network_acl" "nacl" {
  vpc_id = "${data.aws_vpc.vpc_client.id}"
  subnet_ids = ["${aws_subnet.sub_private_1a.id}","${aws_subnet.sub_private_1b.id}","${aws_subnet.sub_public_1a.id}","${aws_subnet.sub_public_1b.id}"]

  egress{
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "${var.customer_cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  egress{
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = "${var.bastion_ip}"
    from_port  = 22
    to_port    = 22
  }

  ingress{
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "${var.customer_cidr_block}"
    from_port  = 22
    to_port    = 22
  }

    ingress{
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = "${var.bastion_ip}"
    from_port  = 22
    to_port    = 22
  }

  tags{
      Name = "nacl_${var.customer}"
  }
}
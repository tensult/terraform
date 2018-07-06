provider "aws" {
  profile = "default"
  region  = "${var.region}"
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr_block}"

  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "web" {
  count             = "${length(var.web_subnets_cidr_blocks)}"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.web_subnets_cidr_blocks[count.index]}"

  tags = {
    Name = "web-public-${count.index}"
  }

}

resource "aws_subnet" "app" {
  count             = "${length(var.app_subnets_cidr_blocks)}"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.app_subnets_cidr_blocks[count.index]}"

  tags = {
    Name = "app-private-${count.index}"
  }

}

resource "aws_subnet" "db" {
  count             = "${length(var.public_subnets_cidr_blocks)}"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.db_subnets_cidr_blocks[count.index]}"

  tags = {
    Name = "db-private-${count.index}"
  }

}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "${var.vpc_name}"
  }
}

# Create public subnet for common resources like NAT Gateway etc.
resource "aws_subnet" "public" {
  count             = "${length(var.public_subnets_cidr_blocks)}"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.public_subnets_cidr_blocks[count.index]}"

  tags = {
    Name = "public-${count.index}"
  }
}

# Create Route tables for public layer
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Public"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr_blocks)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# Create Elastic IP for NAT gateway
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "Nat Gateway IP"
  }
}

# Create an NAT gateway to give our private subnets to access to the outside world

resource "aws_nat_gateway" "default" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"

  tags = {
    Name = "${var.vpc_name}"
  }
}

# Create Route tables for web layer
resource "aws_route_table" "web" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Web"
  }
}

resource "aws_route_table_association" "web" {
  count          = "${length(var.web_subnets_cidr_blocks)}"
  subnet_id      = "${element(aws_subnet.web.*.id, count.index)}"
  route_table_id = "${aws_route_table.web.id}"
}

# Create Route tables for App layer

resource "aws_route_table" "app" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.default.id}"
  }

  tags {
    Name = "App"
  }
}

resource "aws_route_table_association" "app" {
  count          = "${length(var.app_subnets_cidr_blocks)}"
  subnet_id      = "${element(aws_subnet.app.*.id, count.index)}"
  route_table_id = "${aws_route_table.app.id}"
}

# Create Route tables for App layer

resource "aws_route_table" "db" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.default.id}"
  }

  tags {
    Name = "DB"
  }
}

resource "aws_route_table_association" "db" {
  count          = "${length(var.db_subnets_cidr_blocks)}"
  subnet_id      = "${element(aws_subnet.db.*.id, count.index)}"
  route_table_id = "${aws_route_table.db.id}"
}

# Create RDS subnet group

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.rds_subnet_name}"
  subnet_ids = ["${aws_subnet.db.*.id}"]

  tags {
    Name = "${var.rds_subnet_name}"
  }
}

# Create RDS instance 

resource "aws_db_instance" "rds" {
  allocated_storage    = "${var.rds_storage}"
  engine               = "${var.rds_engine}"
  instance_class       = "${var.rds_instance_class}"
  name                 = "${var.rds_name}"
  username             = "${var.rds_username}"
  password             = "${var.rds_password}"
  db_subnet_group_name = "${var.rds_subnet_name}"
  depends_on = ["aws_db_subnet_group.rds_subnet_group"]
}

# Create security group for webservers

resource "aws_security_group" "webserver_sg" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.websg_name}"
  }
}

# Create EC2 instances for webservers

resource "aws_instance" "webservers" {
  count           = "${length(var.web_subnets_cidr_blocks)}"
  ami             = "${var.web_ami}"
  instance_type   = "${var.web_instance}"
  security_groups = ["${aws_security_group.webserver_sg.id}"]
  subnet_id       = "${element(aws_subnet.web.*.id,count.index)}"

  tags {
    Name = "${element(var.webserver_name,count.index)}"
  }
}

# Creating application load balancer

resource "aws_lb" "weblb" {
  name               = "${var.lb_name}"
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.webserver_sg.id}"]
  subnets            = ["${aws_subnet.web.*.id}"]

  tags {
    Name = "${var.lb_name}"
  }
}

# Creating load balancer target group

resource "aws_lb_target_group" "alb_group" {
  name     = "${var.tg_name}"
  port     = "${var.tg_port}"
  protocol = "${var.tg_protocol}"
  vpc_id   = "${aws_vpc.default.id}"
}

#Creating listeners

resource "aws_lb_listener" "webserver-lb" {
  load_balancer_arn = "${aws_lb.weblb.arn}"
  port              = "${var.listener_port}"
  protocol          = "${var.listener_protocol}"

  # certificate_arn  = "${var.certificate_arn_user}"
  default_action {
    target_group_arn = "${aws_lb_target_group.alb_group.arn}"
    type             = "forward"
  }
}

#Creating listener rules

resource "aws_lb_listener_rule" "allow_all" {
  listener_arn = "${aws_lb_listener.webserver-lb.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alb_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}

# Define Bastion Host Security Group

data "aws_security_group" "bastion"{
  id = "${var.sg_bastion}"
}

# Create security group for Application Load Balancer

resource "aws_security_group" "sg_alb" {
  name        = "sg_${var.customer}_alb"
  description = "Security Group for ${var.customer} Application Load Balancer"
  vpc_id      = "${data.aws_vpc.vpc_client.id}"
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg_${var.customer}_alb"
  }
}

# Create security group for appserver

resource "aws_security_group" "sg_appserver" {
  name        = "sg_${var.customer}_appserver"
  description = "Security Group for ${var.customer} App Server"
  vpc_id      = "${data.aws_vpc.vpc_client.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.sg_alb.id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${var.sg_bastion}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg_${var.customer}_appserver"
  }
}

# Create security group for MongoDB Server

resource "aws_security_group" "sg_mongodb" {
  name        = "sg_${var.customer}_mongodb"
  description = "Security Group for ${var.customer} MongoDB Server"
  vpc_id      = "${data.aws_vpc.vpc_client.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.sg_appserver.id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${var.sg_bastion}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg_${var.customer}_mongodb"
  }
}

# Create security group for RDS Database

resource "aws_security_group" "sg_rds" {
  name        = "sg_${var.customer}_rds"
  description = "Security Group for ${var.customer} RDS Database"
  vpc_id      = "${data.aws_vpc.vpc_client.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.sg_mongodb.id}"]
  }

    ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.sg_appserver.id}"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${var.sg_bastion}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg_${var.customer}_rds"
  }
}
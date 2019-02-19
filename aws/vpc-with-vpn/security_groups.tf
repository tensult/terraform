# SG for Bastion Host
resource "aws_security_group" "sg_bastion" {
  name        = "sg_bastion_host"
  description = "SG for Bastion Host"
  vpc_id      = "${aws_vpc.shared.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
  tags = {
    Name = "sg_bastion_host"
  }
}

# SG for Web Server Load Balancer
resource "aws_security_group" "sg_web_alb" {
  name = "sg_sshArch_alb"
  description = "Security Group web server load balancer"
  vpc_id      = "${aws_vpc.shared.id}"

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
  tags = {
    Name = "sg_sshArch_alb"
  }
}
# # SG for App Server Load Balancer
# resource "aws_security_group" "sg_app_alb" {
#   name        = "sg_app_alb"
#   description = "SG for App Server ALB"
#   vpc_id      = "${aws_vpc.shared.id}"

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     security_groups = ["${aws_security_group.sg_web.id}"]
#   }

#   egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
    
#   }
#   tags = {
#     Name = "sg_app_alb"
#   }
# }

# SG for Web Server 
resource "aws_security_group" "sg_web" {
  name        = "sg_sshArch"
  description = "Security group for Web Server"
  vpc_id      = "${aws_vpc.shared.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.sg_web_alb.id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.sg_bastion.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
  tags = {
    Name = "sg_sshArch"
  }
}

#SG for App Server
resource "aws_security_group" "sg_app" {
  name        = "sg_iopted"
  description = "Security group for App Server"
  vpc_id      = "${aws_vpc.shared.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.sg_web_alb.id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.sg_bastion.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
  tags = {
    Name = "sg_iopted"
  }
}

#SG for RDS

resource "aws_security_group" "sg_rds" {
  name        = "sg_rds_dbopt"
  description = "Security group for RDS database"
  vpc_id      = "${aws_vpc.shared.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.sg_app.id}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.sg_web.id}"]
  }

  ingress {
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    security_groups = ["${aws_security_group.sg_bastion.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
  tags = {
    Name = "sg_rds_dbopt"
  }
}



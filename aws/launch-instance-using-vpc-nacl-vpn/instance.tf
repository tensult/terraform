


# Create EC2 instances for App Server

resource "aws_instance" "appserver" {
  ami             = "${var.instance_ami}"
  instance_type   = "t2.medium"
  subnet_id = ["${aws_subnet.sub_private_1a.id}"]
  associate_public_ip_address = "False"
  volume_type = "gp2"
  volume_size = "15"
  delete_on_termination = "true"
  security_groups = ["${aws_security_group.sg_appserver.id}"]
  key_name = "app-server"

  tags {
    Name = "${var.customer}-APP-1a"
  }

  volume_tags {
    Name = "${var.customer}-APP-1a"
  }
}

# Create EC2 instances for Mongo DB Server

resource "aws_instance" "mongodb" {
  ami             = "${var.instance_ami}"
  instance_type   = "t2.small"
  subnet_id = ["${aws_subnet.sub_private_1a.id}"]
  associate_public_ip_address = "False"
  volume_type = "gp2"
  volume_size = "20"
  delete_on_termination = "true"
  security_groups = ["${aws_security_group.sg_mongodb.id}"]
  key_name = "mongodb-server"

  tags {
    Name = "${var.customer}-MONGODB-1a"
  }

  volume_tags {
    Name = "${var.customer}-MONGO-1a"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage = 100
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.6.40"
  instance_class = "db.t2.medium"
  multi_az = "true"
  name = "rds-${var.customer}"
  username = "${var.dbuser}"
  password = "${var.dbpasswd}"
  parameter_group_name = "default.mysql5.6"
  deletion_protection = "true"
  availability_zone = "ap-south-1a"
  db_subnet_group_name = ["${aws_db_subnet_group.sgs.id}"]
  vpc_security_group_ids = ["${aws_security_group.sg_rds.id}"]
  port = "3306"
  publicly_accessible = "false"
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  kms_key_id = "${var.kms_key}"
}

resource "aws_db_subnet_group" "sgs" {
  name       = "sgs_${var.customer}"
  subnet_ids = ["${aws_subnet.sub_private_1a.id}", "${aws_subnet.sub_private_1b.id}"]

  tags {
    Name = "sgs_${var.customer}"
  }
}
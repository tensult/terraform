# Create EC2 instances for App Server

resource "aws_instance" "appserver" {
  ami                           = "${var.instance_ami}"
  instance_type                 = "t2.medium"
  subnet_id                     = "${aws_subnet.sub_private_1a.id}"
  associate_public_ip_address   = "False"
  vpc_security_group_ids        = ["${aws_security_group.sg_appserver.id}"]
  key_name                      = "app-server"
  root_block_device = {
    volume_type                 = "gp2"
    volume_size                 = "8"
    delete_on_termination       = true
  }
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "15"
    delete_on_termination = false
  }

  tags {
    Name = "${var.customer}-APP-1a"
  }

  volume_tags {
    Name = "${var.customer}-APP-1a"
  }
}

resource "aws_instance" "appserver01" {
  ami                           = "${var.instance_ami}"
  instance_type                 = "t2.medium"
  subnet_id                     = "${aws_subnet.sub_private_1b.id}"
  associate_public_ip_address   = "False"
  vpc_security_group_ids        = ["${aws_security_group.sg_appserver.id}"]
  key_name                      = "app-server"
  root_block_device = {
    volume_type                 = "gp2"
    volume_size                 = "8"
    delete_on_termination       = true
  }
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "15"
    delete_on_termination = false
  }

  tags {
    Name = "${var.customer}-APP-1b"
  }

  volume_tags {
    Name = "${var.customer}-APP-1b"
  }
}

# Create EC2 instances for Mongo DB Server

resource "aws_instance" "mongodb" {
  ami                         = "${var.instance_ami}"
  instance_type               = "t2.small"
  subnet_id                   = "${aws_subnet.sub_private_1a.id}"
  associate_public_ip_address = "False"
  vpc_security_group_ids      = ["${aws_security_group.sg_mongodb.id}"]
  key_name                    = "mongodb-server"
  root_block_device = {
    volume_type                 = "gp2"
    volume_size                 = "8"
    delete_on_termination       = true
  }
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "20"
    delete_on_termination = false
  }

  tags {
    Name = "${var.customer}-MONGODB-1a"
  }

  volume_tags {
    Name = "${var.customer}-MONGO-1a"
  }
}

resource "aws_instance" "mongodb01" {
  ami                         = "${var.instance_ami}"
  instance_type               = "t2.small"
  subnet_id                   = "${aws_subnet.sub_private_1b.id}"
  associate_public_ip_address = "False"
  vpc_security_group_ids      = ["${aws_security_group.sg_mongodb.id}"]
  key_name                    = "mongodb-server"
  root_block_device = {
    volume_type                 = "gp2"
    volume_size                 = "8"
    delete_on_termination       = true
  }
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "20"
    delete_on_termination = false
  }

  tags {
    Name = "${var.customer}-MONGODB-1b"
  }

  volume_tags {
    Name = "${var.customer}-MONGO-1b"
  }
}
provider "aws" {
  region  = "${var.region}"
  profile = "default"
}

provider "aws" {
  alias  = "peer"
  region = "${var.peering_region}"

  #Enter the name of the second profile here
  profile = "prod"
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr_block}"

  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "dms_subnets" {
  count             = "${length(var.dms_subnets_cidr_blocks)}"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.dms_subnets_cidr_blocks[count.index]}"

  tags = {
    Name = "dms-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "rds_subnets" {
  count             = "${length(var.db_subnets_cidr_blocks)}"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.db_subnets_cidr_blocks[count.index]}"

  tags = {
    Name = "db-subnet-${count.index+1}"
  }
}

# Create RDS subnet group

resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "${var.db_subnet_name}"
  subnet_ids = ["${aws_subnet.rds_subnets.*.id}"]

  tags {
    Name = "${var.db_subnet_name}"
  }
}

#Create security group for DMS instance

resource "aws_security_group" "dms_sg" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all"
  }
}

# Create RDS instance 

resource "aws_db_instance" "rds" {
  allocated_storage    = "${var.db_storage}"
  engine               = "${var.db_engine}"
  instance_class       = "${var.db_instance_class}"
  name                 = "${var.db_name}"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  db_subnet_group_name = "${var.db_subnet_name}"
  depends_on = ["aws_db_subnet_group.mysql_subnet_group"]
}

# Create a new replication subnet group

resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
  replication_subnet_group_description = "${var.dms_subnet_desc}"
  replication_subnet_group_id          = "${var.dms_subnet_id}"

  subnet_ids = ["${aws_subnet.dms_subnets.*.id}"]

  tags {
    Name = "${var.dms_subnet_name}"
  }
}

# Create a replication instance

resource "aws_dms_replication_instance" "mysql_dms" {
  allocated_storage           = "${var.dms_instance_storage}"
  publicly_accessible         = false
  replication_instance_class  = "${var.dms_instance_class}"
  replication_instance_id     = "${var.dms_instance_id}"
  replication_subnet_group_id = "${var.dms_subnet_id}"
  depends_on = ["aws_dms_replication_subnet_group.dms_subnet_group"]

  vpc_security_group_ids = [
    "${aws_security_group.dms_sg.id}",
  ]

  tags {
    Name = "${var.dms_subnet_name}"
  }
}

# Create target endpoint

resource "aws_dms_endpoint" "target_endpoint" {
  database_name = "${var.db_name}"
  endpoint_id   = "${var.dms_target_endpoint_id}"
  endpoint_type = "target"
  engine_name   = "${var.db_engine}"
  username      = "${var.db_username}"
  password      = "${var.db_password}"
  port          = 3306
  ssl_mode      = "none"
  server_name   = "${aws_db_instance.rds.address}"

  tags {
    Name = "target_endpoint_dms"
  }
}

#Getting source DB data

data "aws_db_instance" "source_db" {
  db_instance_identifier = "${var.source_db_identifier}"
  provider               = "aws.peer"
}

# Create source endpoint

resource "aws_dms_endpoint" "source_endpoint" {
  database_name = "${data.aws_db_instance.source_db.db_name}"
  endpoint_id   = "${var.dms_source_endpoint_id}"
  endpoint_type = "source"
  engine_name   = "${data.aws_db_instance.source_db.engine}"
  username      = "${data.aws_db_instance.source_db.master_username}"
  password      = "${var.sourcedb_password}"
  port          = 3306
  ssl_mode      = "none"
  server_name   = "${data.aws_db_instance.source_db.address}"

  tags {
    Name = "source_endpoint_dms"
  }
}

# Creating VPC peering connection

data "aws_vpc" "source_vpc" {
  id       = "${var.peering_vpc_id}"
  provider = "aws.peer"
}

resource "aws_vpc_peering_connection" "vpc_peer" {
  peer_owner_id = "${var.peering_owner_id}"
  peer_vpc_id   = "${var.peering_vpc_id}"
  vpc_id        = "${aws_vpc.default.id}"
  peer_region   = "${var.peering_region}"
  auto_accept   = false

  tags {
    Name = "${var.peering_name}"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "vpc_peer" {
  provider                  = "aws.peer"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peer.id}"
  auto_accept               = true

  tags {
    Name = "${var.peering_name}"
    Side = "Accepter"
  }
}

# Create Route tables for target VPC
resource "aws_route_table" "target_route_table" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "${data.aws_vpc.source_vpc.cidr_block}"
    gateway_id = "${aws_vpc_peering_connection.vpc_peer.id}"
  }

  tags {
    Name = "Peering connection for target VPC"
  }
}

resource "aws_route_table_association" "target_association" {
  count          = "${length(var.dms_subnets_cidr_blocks)}"
  subnet_id      = "${element(aws_subnet.dms_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.target_route_table.id}"
}

# Create Route tables for source VPC
resource "aws_route_table" "source_route_table" {
  provider = "aws.peer"
  vpc_id   = "${data.aws_vpc.source_vpc.id}"

  route {
    cidr_block = "${var.vpc_cidr_block}"
    gateway_id = "${aws_vpc_peering_connection.vpc_peer.id}"
  }

  tags {
    Name = "Peering connection for source VPC"
  }
}

data "aws_subnet_ids" "source_subnets" {
  provider = "aws.peer"
  vpc_id   = "${data.aws_vpc.source_vpc.id}"
}

resource "aws_route_table_association" "source_association" {
  provider       = "aws.peer"
  count          = "${length(data.aws_subnet_ids.source_subnets.ids)}"
  subnet_id      = "${element(data.aws_subnet_ids.source_subnets.ids, count.index)}"
  route_table_id = "${aws_route_table.source_route_table.id}"
}

#Adding rules for target security group

resource "aws_security_group_rule" "target_db" {
  type      = "ingress"
  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"

  #cidr_blocks     = ["${data.aws_vpc.source_vpc.cidr_block}"]
  source_security_group_id = "${aws_security_group.dms_sg.id}"
  security_group_id        = "${element(aws_db_instance.rds.vpc_security_group_ids,0)}"
}

#Adding rules for source security group

resource "aws_security_group_rule" "source_db" {
  provider          = "aws.peer"
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["${aws_vpc.default.cidr_block}"]
  security_group_id = "${element(data.aws_db_instance.source_db.vpc_security_groups,0)}"
}

# Create a new replication task

resource "aws_dms_replication_task" "dms_terraform_task" {
  migration_type           = "${var.dms_migration_type}"
  replication_instance_arn = "${aws_dms_replication_instance.mysql_dms.replication_instance_arn}"
  replication_task_id      = "${var.dms_replication_task_id}"
  source_endpoint_arn      = "${aws_dms_endpoint.source_endpoint.endpoint_arn}"
  target_endpoint_arn      = "${aws_dms_endpoint.target_endpoint.endpoint_arn}"
  table_mappings           = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"

  tags {
    Name = "${var.dms_replication_task_name}"
  }
}

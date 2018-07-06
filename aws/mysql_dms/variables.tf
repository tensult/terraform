variable "region" {
  description = "AWS region to create VPC"
  default     = "us-west-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  default     = "172.20.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  default     = "mysql_dms_vpc"
}

variable "dms_subnets_cidr_blocks" {
  description = "CIDR block for VPC"
  default     = ["172.20.1.0/24", "172.20.7.0/24"]
}

variable "db_subnets_cidr_blocks" {
  description = "CIDR blocks of subnets"
  default     = ["172.20.3.0/24", "172.20.5.0/24"]
}

variable "db_subnet_name" {
  description = "Name of the RDS subnet group"
  default     = "mysql_db_group"
}

variable "db_storage" {
  description = "RDS storage space"
  default     = "10"
}

variable "db_engine" {
  description = "RDS engine type"
  default     = "mysql"
}

variable "db_instance_class" {
  description = "RDS instance class"
  default     = "db.t2.micro"
}

variable "db_name" {
  description = "Name of the RDS"
  default     = "mysqldb"
}

variable "db_username" {
  description = "Username of the RDS"
  default     = "mysql_terraform"
}

variable "db_password" {
  description = "Password of the RDS"
  default     = "terraformdb"
}

variable "dms_subnet_desc" {
  description = "Description of DMS subnet group"
  default     = "Testing DMS by terraform"
}

variable "dms_subnet_id" {
  description = "ID of DMS subnet group"
  default     = "dms-subnet-group-terraform"
}

variable "dms_subnet_name" {
  description = "Name of DMS subnet group"
  default     = "dms-subnet-terraform"
}

variable "dms_instance_storage" {
  description = "Storage of the DMS instance"
  default     = "20"
}

variable "dms_instance_class" {
  description = "Class of the DMS instance"
  default     = "dms.t2.micro"
}

variable "dms_instance_id" {
  description = "ID of the DMS instance"
  default     = "dms-mysql-terraform"
}

variable "dms_instance_name" {
  description = "Name of the DMS instance"
  default     = "dms-mysql-terraform"
}

variable "dms_target_endpoint_id" {
  description = "DMS target endpoint ID"
  default     = "dms-endpoint-target-mysql"
}

variable "dms_source_endpoint_id" {
  description = "DMS source endpoint ID"
  default     = "dms-endpoint-source-mysql"
}

# Enter the source DB details here
variable "source_db_identifier" {
  description = "Enter source DB identifier"
  default     = "mysqlterraform123"
}

variable "sourcedb_password" {
  description = "Password of the source"
  default     = "mysqlterraform"
}

variable "peering_owner_id" {
  description = "AWS account ID of the owner of the peer VPC"
  default     = "173268405833"
}

# Enter VPC id of the accepting VPC here for peering
variable "peering_vpc_id" {
  description = "ID of the VPC with which you are creating the VPC Peering Connection"
  default     = "vpc-1234"
}

variable "peering_name" {
  description = "Name of the VPC peering connection"
  default     = "terraform_test"
}

# Enter peering region
variable "peering_region" {
  description = "VPC peering region"
  default     = "ap-south-1"
}

variable "dms_replication_task_id" {
  description = "ID of the replication task"
  default     = "terraform-dr-mysql"
}

variable "dms_replication_task_name" {
  description = "Name of the replication task"
  default     = "mysql_dms_task"
}

variable "dms_migration_type" {
  description = "Type of migration. Can be one of full-load | cdc | full-load-and-cdc"
  default     = "full-load"
}

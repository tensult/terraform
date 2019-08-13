provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# VPC - Production & Staging
module "vpc" {
  source              = "./network"
  cidr                = "${var.cidr}"
  vpc_name            = "${var.vpc_name}"
  cluster_name        = "${module.eks.cluster-name}"
  master_subnet_cidr  = "${var.master_subnet_cidr}"
  worker_subnet_cidr  = "${var.worker_subnet_cidr}"
  public_subnet_cidr  = "${var.public_subnet_cidr}"
  private_subnet_cidr = "${var.private_subnet_cidr}"
}

module "kubernetes-server" {
  source        = "./kubernetes-server"
  instance_type = "${var.instance_type}"
  instance_ami  = "${var.instance-ami}"
  server-name   = "${var.server-name}"
  instance_key  = "${var.key}"
  vpc_id        = "${module.vpc.vpc_id}"
  k8-subnet     = "${module.vpc.public_subnet[0]}"
}

module "eks" {
  source                        = "./cluster"
  vpc_id                        = "${module.vpc.vpc_id}"
  cluster-name                  = "${var.cluster-name}"
  kubernetes-server-instance-sg = "${module.kubernetes-server.kubernetes-server-instance-sg}"
  eks_subnets                   = ["${module.vpc.master_subnet}"]
  worker_subnet                 = ["${module.vpc.worker_node_subnet}"]
  subnet_ids                    = ["${module.vpc.master_subnet}", "${module.vpc.worker_node_subnet}"]
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# VPC - Production & Staging
module "vpc" {
  source              = "./network"
  cidr                = "10.0.0.0/16"
  vpc_name            = "${var.vpc_name}"
  cluster_name        = "${module.eks.cluster-name}"
  master_subnet_cidr  = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
  worker_subnet_cidr  = ["10.0.144.0/20", "10.0.160.0/20", "10.0.176.0/20"]
  public_subnet_cidr  = ["10.0.204.0/22", "10.0.208.0/22", "10.0.212.0/22"]
  private_subnet_cidr = ["10.0.228.0/22", "10.0.232.0/22", "10.0.236.0/22"]
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

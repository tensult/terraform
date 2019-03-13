data "template_file" "mongodb_replication_primary" {
  template = "${file("mongodb_replication_primary.json")}"

  vars {
    customer = "${var.customer}"
    region = "${var.region}"
    mongo_file = "${var.mongo_file}"
  }
}

resource "aws_ssm_document" "mongodb_replication_primary" {
  name          = "Launch_Automation_for_mongodb_replication_primary"
  document_type = "Automation"

  content = "${data.template_file.mongodb_replication_primary.rendered}"
}

data "template_file" "mongodb_replication_secondary" {
  template = "${file("mongodb_replication_secondary.json")}"

  vars {
    customer = "${var.customer}"
    region = "${var.region}"
    mongo_file = "${var.mongo_file}"
  }
}

resource "aws_ssm_document" "mongodb_replication_secondary" {
  name          = "Launch_Automation_for_mongodb_replication_secondary"
  document_type = "Automation"

  content = "${data.template_file.mongodb_replication_secondary.rendered}"
}
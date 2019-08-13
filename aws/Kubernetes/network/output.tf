output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.this.id}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${aws_vpc.this.cidr_block}"
}

output "master_subnet" {
  value = ["${aws_subnet.master_subnet.*.id}"]
}

output "public_subnet" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "private_subnet" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}

output "worker_node_subnet" {
  value = ["${aws_subnet.worker_subnet.*.id}"]
}

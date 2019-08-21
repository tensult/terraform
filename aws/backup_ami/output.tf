output "ami_id" {
  value = "${aws_ami_from_instance.ami-backup.id}"
}

output "ami_name" {
  value = "${aws_ami_from_instance.ami-backup.name}"
}

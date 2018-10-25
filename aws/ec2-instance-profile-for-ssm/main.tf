provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2-Managed-Instance-Profile"
  role = "${aws_iam_role.role.name}"
}

resource "aws_iam_role" "role" {
  name = "EC2-Managed-Instance-Role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
    role       = "${aws_iam_role.role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
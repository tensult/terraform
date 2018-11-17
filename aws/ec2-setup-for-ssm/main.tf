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

resource "aws_kms_key" "ssm" {
  description             = "KMS key for SSM"
}

resource "aws_kms_alias" "ssm_key_alias" {
  name          = "alias/ssm-key"
  target_key_id = "${aws_kms_key.ssm.key_id}"
}


resource "aws_iam_role_policy_attachment" "ssm-policy" {
    role       = "${aws_iam_role.role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "cloudwatch-agent-policy" {
    role       = "${aws_iam_role.role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm-params-policy" {
    role       = "${aws_iam_role.role.name}"
    policy_arn = "${aws_iam_policy.ssm_params.arn}"
}

resource "aws_iam_role_policy_attachment" "inspector-full-access" {
    role       = "${aws_iam_role.role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonInspectorFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3-private-static" {
    role       = "${aws_iam_role.role.name}"
    policy_arn = "${aws_iam_policy.private_static_s3.arn}"
}
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

resource "aws_kms_key" "ssm" {
  description             = "KMS key for SSM"
}

resource "aws_kms_alias" "ssm_key_alias" {
  name          = "alias/ssm-key"
  target_key_id = "${aws_kms_key.ssm.key_id}"
}

resource "aws_iam_policy" "ssm_params" {
  name = "EC2-Managed-Instance-SSM-Params"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "kms:Decrypt"
           ],
           "Resource": "${aws_kms_key.ssm.arn}"
       },
       {
           "Effect": "Allow",
           "Action": [
               "ssm:GetParameter"
           ],
           "Resource": "arn:aws:ssm:*:*:parameter/domain/*"
       }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
    role       = "${aws_iam_role.role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ssm-params-policy" {
    role       = "${aws_iam_role.role.name}"
    policy_arn = "${aws_iam_policy.ssm_params.arn}"
}
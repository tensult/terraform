#Define Policy
resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#Attach policy
resource "aws_iam_role_policy_attachment" "test-attach" {
    role       = "${aws_iam_role.cross-account.name}"
    policy_arn = "${aws_iam_policy.policy.arn}"
}
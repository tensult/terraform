#Create Cross Account Role
resource "aws_iam_role" "cross-acc" {
  name = "Tensult_Admin"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.requester_account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
}

#Attach policy
resource "aws_iam_role_policy_attachment" "test-attach" {
    role       = "${aws_iam_role.cross-acc.name}"
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
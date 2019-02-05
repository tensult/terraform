# Policy for Power User Access
data "aws_iam_policy" "power_user" {
  arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Policy for ReadOnly Access
data "aws_iam_policy" "readonly" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Policy for Iam Limited Access
resource "aws_iam_policy" "iam_limit_access" {
    name        = "iam_limit_access"
   description = "iam_limit_access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:CreatePolicy",
        "iam:CreateInstanceProfile",
        "iam:PassRole",
        "iam:CreateRole",
        "iam:AttachRolePolicy", 
        "iam:AddRoleToInstanceProfile",
        "iam:PutRolePolicy"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
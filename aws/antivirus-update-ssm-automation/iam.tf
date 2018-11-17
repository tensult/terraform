resource "aws_iam_role" "cloudwatch_event_rule" {
  name = "Windows_Antivirus_Update_Automation"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudwatch_event_rule" {
  name = "Windows_Antivirus_Update_Automation"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "ec2:DescribeInstances",
               "ec2:StartInstances",
               "ec2:StopInstances",
               "ssm:SendCommand"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
    role       = "${aws_iam_role.cloudwatch_event_rule.name}"
    policy_arn = "${aws_iam_policy.cloudwatch_event_rule.arn}"
}
resource "aws_iam_role" "cloudwatch_event_target" {
  name = "Antivirus_Update_Automation"

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

resource "aws_iam_policy" "cloudwatch_event_target" {
  name = "Antivirus_Update_Automation"

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
resource "aws_iam_role_policy_attachment" "av_update_ssm_automation" {
    role       = "${aws_iam_role.cloudwatch_event_target.name}"
    policy_arn = "${aws_iam_policy.cloudwatch_event_target.arn}"
}
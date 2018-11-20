resource "aws_iam_role" "instance_launch_automation" {
  name = "Instance-Launch-Automation"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com", 
          "ssm.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "instance_launch_automation" {
  name = "Instance-Launch-Automation"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "ec2:CreateTags",
               "ec2:DescribeInstances",
               "ec2:DescribeInstanceStatus",
               "iam:PassRole",
               "ssm:*"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
    role       = "${aws_iam_role.instance_launch_automation.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_main_policy_attachment" {
    role       = "${aws_iam_role.instance_launch_automation.name}"
    policy_arn = "${aws_iam_policy.instance_launch_automation.arn}"
}
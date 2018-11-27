provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

resource "aws_iam_role" "lambda_role" {
  name = "EC2-Auto-Stop-Lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "EC2-Auto-Stop"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "ec2:DescribeInstances",
               "ec2:DescribeRegions",
               "ec2:StopInstances"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_main_policy_attachment" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "${data.archive_file.lambda_code.output_path}"
  function_name    = "EC2-Auto-Stop"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "lambda.handler"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda_code.output_path}"))}"
  runtime          = "nodejs8.10"
  timeout          = "300"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.daily_stop.arn}"
}

resource "aws_cloudwatch_event_rule" "daily_stop" {
  name                = "Daily-EC2-Stop-instances"
  description         = "Stops the instances"
  schedule_expression = "cron(0 16 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_trigger" {
  rule      = "${aws_cloudwatch_event_rule.daily_stop.name}"
  target_id = "${aws_lambda_function.lambda_function.function_name}"
  arn       = "${aws_lambda_function.lambda_function.arn}"
}

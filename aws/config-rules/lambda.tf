resource "aws_iam_role" "lambda_role" {
  name = "Config-Rule-Lambda"

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
  name = "Config-Rule-Lambda"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "config:GetResourceConfigHistory",
               "config:PutEvaluations",
               "ses:SendEmail"
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

data "archive_file" "security_groups" {
  type        = "zip"
  source_dir  = "sg-lambda"
  output_path = "sg-lambda.zip"
}

resource "aws_lambda_function" "security_groups" {
  filename         = "${data.archive_file.security_groups.output_path}"
  function_name    = "Config-Rule-SecurityGroups-Checker"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "security_groups.handler"
  source_code_hash = "${base64sha256(file("${data.archive_file.security_groups.output_path}"))}"
  runtime          = "nodejs8.10"
  timeout          = "300"

  environment {
    variables = {
      notificationEmails = "${coalesce(var.notification_emails, var.ses_email)}"
      sesEmail           = "${var.ses_email}"
      accountName        = "${var.account_name}"
      adminEmail         = "${var.admin_email}"
      company_name       = "${var.company_name}"
    }
  }
}

resource "aws_lambda_permission" "security_groups" {
  statement_id  = "AllowExecutionFromConfig"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.security_groups.function_name}"
  principal     = "config.amazonaws.com"
}

data "archive_file" "instance_tags" {
  type        = "zip"
  source_file = "instance_tags.js"
  output_path = "instnace-tags-lambda.zip"
}

resource "aws_lambda_function" "instance_tags" {
  filename         = "${data.archive_file.instance_tags.output_path}"
  function_name    = "Config-Rule-Instance-Tags-Checker"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "instance_tags.handler"
  source_code_hash = "${base64sha256(file("${data.archive_file.instance_tags.output_path}"))}"
  runtime          = "nodejs8.10"
  timeout          = "300"

  environment {
    variables = {
      accountName = "${var.account_name}"
    }
  }
}

resource "aws_lambda_permission" "instance_tags" {
  statement_id  = "AllowExecutionFromConfig"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.instance_tags.function_name}"
  principal     = "config.amazonaws.com"
}

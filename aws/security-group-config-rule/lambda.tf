resource "aws_iam_role" "lambda_role" {
  name = "Security-Group-Rules-Checker"

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
               "config:PutEvaluations"
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
  function_name    = "Config-Rule-SecurityGroups-Checker"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "lambda.handler"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda_code.output_path}"))}"
  runtime          = "nodejs8.10"
  timeout          = "300"
}

resource "aws_lambda_permission" "allow_config" {
  statement_id   = "AllowExecutionFromConfig"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.lambda_function.function_name}"
  principal      = "config.amazonaws.com"
}
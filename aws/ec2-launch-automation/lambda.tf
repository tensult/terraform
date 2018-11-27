data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "${data.archive_file.lambda_code.output_path}"
  function_name    = "Launch-EC2-Instance-Automation"
  role             = "${aws_iam_role.instance_launch_automation.arn}"
  handler          = "lambda.handler"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda_code.output_path}"))}"
  runtime          = "nodejs8.10"
  timeout          = "300"

  environment {
    variables = {
      LAUNCH_AUTOMATION_DOCUMENT_AMAZON_LINUX = "${aws_ssm_document.amazon_linux_automation.name}"
      LAUNCH_AUTOMATION_DOCUMENT_REDHAT_LINUX = "${aws_ssm_document.redhat_linux_automation.name}"
      LAUNCH_AUTOMATION_DOCUMENT_CENTOS_LINUX = "${aws_ssm_document.centos_linux_automation.name}"
      LAUNCH_AUTOMATION_DOCUMENT_UBUNTU_LINUX = "${aws_ssm_document.ubuntu_linux_automation.name}"
      LAUNCH_AUTOMATION_DOCUMENT_WINDOWS_2012 = "${aws_ssm_document.windows2012_automation.name}"
      LAUNCH_AUTOMATION_DOCUMENT_WINDOWS_2016 = "${aws_ssm_document.windows2016_automation.name}"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ec2_run_instances.arn}"
}

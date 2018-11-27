resource "aws_cloudwatch_event_rule" "weeky_update" {
  name                = "Weekly-Update-Antivirus"
  description         = "Update Antivirus on stopped instances"
  schedule_expression = "cron(0 16 ? * 1 *)"
}

resource "aws_cloudwatch_event_target" "antivirus_update_automation" {
  rule      = "${aws_cloudwatch_event_rule.weeky_update.name}"
  target_id = "${aws_lambda_function.lambda_function.function_name}"
  arn       = "${aws_lambda_function.lambda_function.arn}"
}

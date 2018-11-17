resource "aws_cloudwatch_event_rule" "weeky_update_windows" {
  name        = "Weekly-Update-Antivirus-on-Instances"
  description = "Update Antivirus on stopped instances"
  schedule_expression = "cron(0 16 ? * 1 *)"
}

resource "aws_cloudwatch_event_rule" "weeky_update_linux" {
  name        = "Weekly-Update-Antivirus-on-Instances"
  description = "Update Antivirus on stopped instances"
  schedule_expression = "cron(0 16 ? * 1 *)"
}

resource "aws_cloudwatch_event_target" "ssm_automation_windows" {
  count = 0
  rule      = "${aws_cloudwatch_event_rule.weeky_update_windows.name}"
  arn       = "${aws_ssm_document.windows_av_update_automation.arn}"
  role_arn = "${aws_iam_role.cloudwatch_event_rule.arn}"
}

resource "aws_cloudwatch_event_target" "ssm_automation_linux" {
  count = 0
  rule      = "${aws_cloudwatch_event_rule.weeky_update_linux.name}"
  arn       = "${aws_ssm_document.linux_av_update_automation.arn}"
  role_arn = "${aws_iam_role.cloudwatch_event_rule.arn}"
}
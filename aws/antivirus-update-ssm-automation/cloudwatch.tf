resource "aws_cloudwatch_event_rule" "weeky_update" {
  name        = "Weekly-Update-Antivirus"
  description = "Update Antivirus on stopped instances"
  schedule_expression = "cron(0 16 ? * 1 *)"
}
resource "aws_cloudwatch_event_target" "ssm_automation_windows" {
  count = 0 #Remove count = 0 when terraform adds support
  rule      = "${aws_cloudwatch_event_rule.weeky_update.name}"
  arn       = "${aws_ssm_document.windows_av_update_automation.arn}"
  role_arn = "${aws_iam_role.cloudwatch_event_target.arn}"
}

resource "aws_cloudwatch_event_target" "ssm_automation_linux" {
  count = 0 #Remove count = 0 when terraform adds support
  rule      = "${aws_cloudwatch_event_rule.weeky_update.name}"
  arn       = "${aws_ssm_document.linux_av_update_automation.arn}"
  role_arn = "${aws_iam_role.cloudwatch_event_target.arn}"
}
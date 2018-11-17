resource "aws_cloudwatch_event_rule" "weeky_update" {
  name        = "Weekly-Update-Antivirus-on-Windows-Instances"
  description = "Update Antivirus on Windows stopped instances"
  schedule_expression = "cron(0 16 ? * 1 *)"
}

resource "aws_cloudwatch_event_target" "ssm_automation_trigger" {
  rule      = "${aws_cloudwatch_event_rule.weeky_update.name}"
  target_id = "TriggerSSMAVAutomation"
  arn       = "${aws_ssm_document.av_update_automation.arn}"
  role_arn = "${aws_iam_role.cloudwatch_event_rule.arn}"
}
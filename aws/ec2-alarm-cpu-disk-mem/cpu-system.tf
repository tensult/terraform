resource "aws_cloudwatch_metric_alarm" "cpuutllz" {
  alarm_name                = "${var.app_name}-Server-CPU-Utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "70"
  alarm_description         = "${var.app_name}-Server-CPU-Utilization"
  alarm_actions             = ["${var.sns_topic}"]
  dimensions {
    InstanceId              = "${var.instance_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "system_status_checks" {
  alarm_name                = "${var.app_name}-System-Status-Checks-Failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "${var.app_name}-System-Status-Checks-Failed"
  alarm_actions = ["${var.sns_topic}"]
  dimensions {
    InstanceId = "${var.instance_id}"
  }
}
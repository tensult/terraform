provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}
resource "aws_cloudwatch_metric_alarm" "cpu_util" {
  count = "${length(var.instance_ids)}"
  alarm_name                = "High-CPUUtilization-${var.instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "75"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions = ["${var.sns_topic_arn}"]
  dimensions {
    InstanceId = "${var.instance_ids[count.index]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_status_checks" {
  count = "${length(var.instance_ids)}"
  alarm_name                = "Instance-Status-Checks-Failed-${var.instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed_Instance"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ec2 status checks"
  alarm_actions = ["${var.sns_topic_arn}"]
  dimensions {
    InstanceId = "${var.instance_ids[count.index]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "system_status_checks" {
  count = "${length(var.instance_ids)}"
  alarm_name                = "System-Status-Checks-Failed-${var.instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ec2 status checks"
  alarm_actions = ["${var.sns_topic_arn}"]
  dimensions {
    InstanceId = "${var.instance_ids[count.index]}"
  }
}
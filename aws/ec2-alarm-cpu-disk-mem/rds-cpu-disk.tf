resource "aws_cloudwatch_metric_alarm" "free_space" {
  alarm_name                = "${var.rds_instance}-RDS-Free­Storage­Space"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "Free­Storage­Space"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "${var.freestoragespace}"
  alarm_description         = "${var.rds_instance}-RDS-Free­Storage­Space"
  alarm_actions = ["${var.sns_topic}"]
  dimensions {
    DBInstanceIdentifier = "${var.rds_instance}"
  }
}

resource "aws_cloudwatch_metric_alarm" "free_memory" {
  alarm_name                = "${var.rds_instance}-RDS-Freeable­Memory"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1" #datapoint
  metric_name               = "Freeable­Memory"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "${var.freeablememory}"
  alarm_description         = "${var.rds_instance}-RDS-Freeable­Memory"
  alarm_actions = ["${var.sns_topic}"]
  dimensions {
    DBInstanceIdentifier = "${var.rds_instance}"
  }
}

resource "aws_cloudwatch_metric_alarm" "CPUUtilization" {
  alarm_name                = "${var.rds_instance}-RDS-CPUUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "70"
  alarm_description         = "${var.rds_instance}-RDS-CPUUtilization"
  alarm_actions = ["${var.sns_topic}"]
  dimensions {
    DBInstanceIdentifier = "${var.rds_instance}"
  }
}
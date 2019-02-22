resource "aws_cloudwatch_metric_alarm" "lb_target_responce" {
  alarm_name                = "${var.lb_name}-ALB-Target-Responce-Time"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/Application­ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "0.6"
  alarm_description         = "${var.lb_name}-ALB-Target-Responce-Time"
  alarm_actions             = ["${var.sns_topic}"]
  dimensions {
    LoadBalancer              = "${var.load_balancer}"
  }
}

resource "aws_cloudwatch_metric_alarm" "lb_http_5xx" {
  alarm_name                = "${var.lb_name}-ALB-High-HTTP-5XXs"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "HTTPCode_Target_5XX_Count"
  namespace                 = "AWS/Application­ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "${var.lb_name}-ALB-High-HTTP-5XXs"
  alarm_actions             = ["${var.sns_topic}"]
  dimensions {
    LoadBalancer              = "${var.load_balancer}"
  }
}

resource "aws_cloudwatch_metric_alarm" "tg_unhealthy" {
  alarm_name                = "${var.lb_name}-TG-High-Unhealthy-Hosts"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/Application­ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "0"
  alarm_description         = "${var.lb_name}-TG-High-Unhealthy-Hosts"
  alarm_actions             = ["${var.sns_topic}"]
  dimensions {
    LoadBalancer              = "${var.load_balancer}"
    TargetGroup               = "${var.alb_targetgroup}"
  }
}
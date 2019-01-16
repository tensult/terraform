# Creating application load balancer

resource "aws_lb" "weblb" {
  name               = "${var.lb_name}"
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.webserver_sg.id}"]
  subnets            = ["${aws_subnet.web.*.id}"]

  tags {
    Name = "${var.lb_name}"
  }
}

# Creating load balancer target group

resource "aws_lb_target_group" "alb_group" {
  name     = "${var.tg_name}"
  port     = "${var.tg_port}"
  protocol = "${var.tg_protocol}"
  vpc_id   = "${aws_vpc.default.id}"
}

#Creating listeners

resource "aws_lb_listener" "webserver-lb" {
  load_balancer_arn = "${aws_lb.weblb.arn}"
  port              = "${var.listener_port}"
  protocol          = "${var.listener_protocol}"

  # certificate_arn  = "${var.certificate_arn_user}"
  default_action {
    target_group_arn = "${aws_lb_target_group.alb_group.arn}"
    type             = "forward"
  }
}

#Creating listener rules

resource "aws_lb_listener_rule" "allow_all" {
  listener_arn = "${aws_lb_listener.webserver-lb.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alb_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}
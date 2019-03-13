resource "aws_lb" "web_alb" {
  name                  = "alb-${var.customer}"
  internal              = false
  ip_address_type       = "ipv4"
  load_balancer_type    = "application"
  security_groups       = ["${aws_security_group.sg_alb.id}"]
  subnets               = ["${aws_subnet.sub_public_1a.id}","${aws_subnet.sub_public_1b.id}"]

  tags = {
      Name  = "alb_${var.customer}"
  }
}

resource "aws_lb_listener" "web_alb_http_listener" {
  load_balancer_arn     = "${aws_lb.web_alb.arn}"
  port                  = "8080"
  protocol              = "HTTP"

  default_action        = {
      type              = "forward"
      target_group_arn  = "${aws_lb_target_group.tg_web_alb.arn}"
  }

}

// Web Load balancer target group

resource "aws_lb_target_group" "tg_web_alb" {
  name     = "tg-${var.customer}"
  port     = 8080
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = "${data.aws_vpc.vpc_client.id}"
}


//target group attachment

resource "aws_lb_target_group_attachment" "tg_web_alb_inst_attach_1a" {
    target_group_arn = "${aws_lb_target_group.tg_web_alb.arn}"
    target_id        = "${aws_instance.appserver.id}"
    port             = "8080"
}

resource "aws_lb_target_group_attachment" "tg_web_alb_inst_attach_1b" {
    target_group_arn = "${aws_lb_target_group.tg_web_alb.arn}"
    target_id        = "${aws_instance.appserver01.id}"
    port             = "8080"
}
provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

resource "aws_security_group" "alb_sg" {
  description = "Allow worker nodes pods to communicate with outsiders"
  vpc_id      = "${var.vpc_id}"
  name        = "alb-loadbalancer-sg"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group_rule" "allow_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.alb_sg.id}"
  source_security_group_id = "0.0.0.0/0"
}

resource "aws_security_group_rule" "allow_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.alb_sg.id}"
  source_security_group_id = "0.0.0.0/0"
}

resource "aws_lb" "test" {
  name               = "${var.alb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb_sg.id}"]

  # count                      = "${length(var.subnet_id)}"
  subnets                    = "${var.subnet_id}"
  enable_deletion_protection = false

  tags = {
    Environment = "${var.env}"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "tf-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.test.arn}"
  port              = 443
  protocol          = "HTTPS"

  #ssl_policy        = "_2a3395ae3cfce2315bb8f40c53867cc8.www.vazid.tk."
  certificate_arn = "${var.cer_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alb_tg.arn}"
  }
}

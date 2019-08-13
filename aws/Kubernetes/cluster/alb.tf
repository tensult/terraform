resource "aws_security_group" "eks_alb_sg" {
  description = "Allow worker nodes pods to communicate with outsiders"
  vpc_id      = "${var.vpc_id}"
  name        = "eks-alb-loadbalancer-sg"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-alb-sg"
  }
}

resource "aws_security_group_rule" "allow_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_alb_sg.id}"
  source_security_group_id = "${aws_security_group.worker-node-sg.id}"
}

resource "aws_security_group_rule" "allow_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_alb_sg.id}"
  source_security_group_id = "${aws_security_group.worker-node-sg.id}"
}

resource "aws_security_group_rule" "allow_worker_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_alb_sg.id}"
  source_security_group_id = "${aws_security_group.worker-node-sg.id}"
}

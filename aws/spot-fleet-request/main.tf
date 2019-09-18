# Request a Spot fleet

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

resource "aws_iam_role" "ec2-spot-role" {
  name = "Spot-fleet-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "spotfleet.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "spot-fleet-policy" {
  name = "Spot-fleet-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeImages",
                "ec2:DescribeSubnets",
                "ec2:RequestSpotInstances",
                "ec2:TerminateInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:CreateTags"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": [
                        "ec2.amazonaws.com",
                        "ec2.amazonaws.com.cn"
                    ]
                }
            },
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
} 
EOF
}

resource "aws_iam_role_policy_attachment" "spot-fleet-policy-attachment" {
  role       = "${aws_iam_role.ec2-spot-role.name}"
  policy_arn = "${aws_iam_policy.spot-fleet-policy.arn}"
}

resource "aws_spot_fleet_request" "spot-fleet-request" {
  iam_fleet_role                  = "${aws_iam_role.ec2-spot-role.arn}"
  spot_price                      = "2"
  allocation_strategy             = "diversified"
  target_capacity                 = 1
  instance_interruption_behaviour = "stop"

  launch_specification {
    instance_type = "${var.instance_type1}"
    ami           = "${var.ami_id}"
    key_name      = "${var.key}"

    tags = {
      spot-instance = "true"
    }
  }

  launch_specification {
    instance_type = "${var.instance_type2}"
    ami           = "${var.ami_id}"
    key_name      = "${var.key}"

    tags = {
      spot-instance = "true"
    }
  }

  launch_specification {
    instance_type = "${var.instance_type3}"
    ami           = "${var.ami_id}"
    key_name      = "${var.key}"

    tags = {
      spot-instance = "true"
    }
  }

  launch_specification {
    instance_type = "${var.instance_type4}"
    ami           = "${var.ami_id}"
    key_name      = "${var.key}"

    tags = {
      spot-instance = "true"
    }
  }
}
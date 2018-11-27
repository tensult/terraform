resource "aws_cloudwatch_event_rule" "ec2_run_instances" {
  name        = "EC2-Instance-Launch-Automation"
  description = "Runs automation on EC2 instance launch"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "ec2.amazonaws.com"
    ],
    "eventName": [
      "RunInstances"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "ec2_run_instances" {
  rule      = "${aws_cloudwatch_event_rule.ec2_run_instances.name}"
  target_id = "${aws_lambda_function.lambda_function.function_name}"
  arn       = "${aws_lambda_function.lambda_function.arn}"
}

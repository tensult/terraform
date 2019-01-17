

resource "aws_ssm_parameter" "cloudwatch_parameter" {
  name        = "AmazonCloudWatch-linux"
  description = "Domain username"
  type        = "String"
  overwrite   = true
  value       = "${var.ssm_store}"
}
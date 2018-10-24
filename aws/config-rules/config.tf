resource "aws_config_config_rule" "security_groups" {
  name = "Security-Groups-Rule"
  description = "Checks for open ports"
  
  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = "${aws_lambda_function.security_groups.arn}",
    source_detail {
      message_type = "ConfigurationItemChangeNotification"
    }
  }

  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }

  depends_on = ["aws_config_configuration_recorder.config_recorder"]
}

resource "aws_config_config_rule" "instance_tags" {
  name = "Instance-Tags-Rule"
  description = "Checks if Instance has mandatory tags"
  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = "${aws_lambda_function.instance_tags.arn}",
    source_detail {
      message_type = "ConfigurationItemChangeNotification"
    }
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Instance"]
  }

  depends_on = ["aws_config_configuration_recorder.config_recorder"]
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = "${aws_config_configuration_recorder.config_recorder.name}"
  is_enabled = true
  depends_on = ["aws_config_delivery_channel.s3_delivery"]
}

resource "aws_config_delivery_channel" "s3_delivery" {
  s3_bucket_name = "${var.config_bucket_name}"
  depends_on     = ["aws_config_configuration_recorder.config_recorder"]
}

resource "aws_config_configuration_recorder" "config_recorder" {
  role_arn = "${aws_iam_service_linked_role.config_service_role.arn}"
  recording_group {
    all_supported = false
    include_global_resource_types = false
    resource_types = ["AWS::EC2::SecurityGroup", "AWS::EC2::Instance"]
  }
}

resource "aws_iam_service_linked_role" "config_service_role" {
  aws_service_name = "config.amazonaws.com"
}
variable "profile" {
  description = "AWS Profile"
  default = "default"
}

variable "region" {
  description = "AWS Region"
  default = "ap-south-1"
}

variable "instance_id" {
  description = "EC2 instance ID"
}

variable "app_name" {
  description = "Name of the Application"
}

variable "sns_topic" {
  description = "SNS Topic for Sending CloudWatch Alarm Notification"
}

variable "ssm_store" {
  description = "ssm parameter value"
  type = "string"
  default = <<DOC
  {
    "logs": {
      "logs_collected": {
        "files": {
          "collect_list": [
            {
              "file_path": "/var/log/messages",
              "log_group_name": "messages"
            }
          ]
        }
      }
    },
    "metrics": {
      "append_dimensions": {
        "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
        "ImageId": "${aws:ImageId}",
        "InstanceId": "${aws:InstanceId}",
        "InstanceType": "${aws:InstanceType}"
      },
      "metrics_collected": {
        "cpu": {
          "measurement": [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system"
          ],
          "metrics_collection_interval": 30,
          "totalcpu": false
        },
        "disk": {
          "measurement": [
            "used_percent",
            "inodes_free"
          ],
          "metrics_collection_interval": 30,
          "resources": [
            "*"
          ]
        },
        "diskio": {
          "measurement": [
            "io_time",
            "write_bytes",
            "read_bytes",
            "writes",
            "reads"
          ],
          "metrics_collection_interval": 30,
          "resources": [
            "*"
          ]
        },
        "mem": {
          "measurement": [
            "mem_used_percent"
          ],
          "metrics_collection_interval": 30
        },
        "netstat": {
          "measurement": [
            "tcp_established",
            "tcp_time_wait"
          ],
          "metrics_collection_interval": 30
        },
        "statsd": {
          "metrics_aggregation_interval": 60,
          "metrics_collection_interval": 10,
          "service_address": ":8125"
        },
        "swap": {
          "measurement": [
            "swap_used_percent"
          ],
          "metrics_collection_interval": 30
        }
      }
    }
  }
DOC
}




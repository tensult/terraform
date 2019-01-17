resource "aws_ssm_parameter" "cloudwatch_parameter" {
  name        = "AmazonCloudWatch-linux"
  description = "SSM Parameter for Disk and Memory Utilization"
  type        = "String"
  overwrite   = true
  value       = 
  <<EOF
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
EOF
}
resource "aws_ssm_document" "AWS_Create_Image" {
  name          = "Create_Golden_Images"
  document_type = "Automation"

  content = <<DOC
{
  "schemaVersion": "0.3",
  "description": "Golden image automation",
  "parameters": {
    "instanceId": {
      "type": "String",
      "description": "Golden image server instanceId"
    },
    "accountIds": {
      "type": "StringList",
      "description": "(Optional) Account Ids to share image (AMI)",
      "default": ${jsonencode(var.account_ids)}
    },
    "shareImage": {
      "type": "Boolean",
      "description": "(Optional) should share AMI with accountIds mentioned",
      "default": ${length(var.account_ids) > 0}
    }
  },
  "mainSteps": [{
      "name": "describeInstance",
      "action": "aws:executeAwsApi",
      "inputs": {
        "Service": "ssm",
        "Api": "DescribeInstanceInformation",
        "Filters": [{
          "Key": "InstanceIds",
          "Values": ["{{instanceId}}"]
        }]
      },
      "outputs": [
        {
          "Name": "osType",
          "Selector": "$.InstanceInformationList[0].PlatformName",
          "Type": "String"
        }, 
        {
          "Name": "osVersion",
          "Selector": "$.InstanceInformationList[0].PlatformVersion",
          "Type": "String"
        },
        {
          "Name": "platformType",
          "Selector": "$.InstanceInformationList[0].PlatformType",
          "Type": "String"
        }
      ]
    },
    {
      "name": "prepareInstance",
      "action": "aws:branch",
      "inputs": {
        "Choices": [
          {
            "NextStep": "prepareWindowsInstance",
            "Variable": "{{describeInstance.platformType}}",
            "StringEquals": "Windows"
          }, 
          {
            "NextStep": "prepareLinuxInstance",
            "Variable": "{{describeInstance.platformType}}",
            "StringEquals": "Linux"
          }
        ],
        "Default": "createImage"
      }
    },
    {
      "name": "prepareWindowsInstance",
      "action": "aws:runCommand",
      "onFailure": "step:unsetMcafeeAgentOnWindows",
      "isCritical": false,
      "inputs": {
        "DocumentName": "Windows_Unjoin_Domain",
        "InstanceIds": [
          "{{instanceId}}"
        ]
      },
      "nextStep": "waitForUnJoinWindows"
    },
    {
      "name": "waitForUnJoinWindows",
      "action": "aws:sleep",
      "inputs": {
        "Duration": "PT1M"
      },
      "nextStep": "unsetMcafeeAgentOnWindows"
    },
    {
      "name": "unsetMcafeeAgentOnWindows",
      "action": "aws:runCommand",
      "onFailure": "step:runSysprepForWindows",
      "isCritical": false,
      "inputs": {
          "DocumentName": "AWS-RunPowerShellScript",
          "InstanceIds": ["{{instanceId}}"],
          "Parameters": {
              "commands": [
                  "Invoke-Expression \"C:\\Program Files\\McAfee\\Agent\\maconfig.exe\" -enforce -noguid\n",
                  "echo \"Instance is ready now\""
              ]
          }
      },
      "nextStep": "waitToSysprep"
    },
    {
      "name": "waitToSysprep",
      "action": "aws:sleep",
      "inputs": {
        "Duration": "PT1M"
      },
      "nextStep": "runSysprepForWindows"
    },
    {
      "name": "prepareLinuxInstance",
      "action": "aws:runCommand",
      "onFailure": "step:createImage",
      "isCritical": false,
      "inputs": {
          "DocumentName": "AWS-RunShellScript",
          "InstanceIds": ["{{instanceId}}"],
          "Parameters": {
              "commands": [
                "sudo su -\n",
                "realm leave\n",
                "/opt/McAfee/agent/bin/maconfig -enforce -noguid\n",
                "echo \"Instance is ready now\""
              ]
          }
      },
      "nextStep": "createImage"
    },
    {
      "name": "runSysprepForWindows",
      "action": "aws:runCommand",
      "onFailure": "Abort",
      "inputs": {
        "DocumentName": "AWSEC2-RunSysprep",
        "InstanceIds": [
          "{{instanceId}}"
        ]
      },
      "nextStep": "waitAfterSysprep"
    },
    {
      "name": "waitAfterSysprep",
      "action": "aws:sleep",
      "inputs": {
        "Duration": "PT1M"
      },
      "nextStep": "createImage"
    },
    {
      "name": "createImage",
      "action": "aws:createImage",
      "maxAttempts": 3,
      "timeoutSeconds": 3600,
      "onFailure": "Abort",
      "inputs": {
        "InstanceId": "{{ instanceId }}",
        "ImageName": "{{ describeInstance.osType }}_{{ describeInstance.osVersion }}_{{global:DATE_TIME}}"
      }
    },
    {
      "name": "createTags",
      "action": "aws:createTags",
      "maxAttempts": 3,
      "onFailure": "Abort",
      "inputs": {
          "ResourceType": "EC2",
          "ResourceIds": [
              "{{createImage.ImageId}}"
          ],
          "Tags": [
              {
                  "Key": "Name",
                  "Value": "{{ describeInstance.osType }} {{ global:DATE }}"
              },
              {
                  "Key": "OSVersion",
                  "Value": "{{ describeInstance.osType }} {{ describeInstance.osVersion }}"
              },
              {
                  "Key": "AutomationId",
                  "Value": "{{automation:EXECUTION_ID}}"
              },
              {
                  "Key": "SourceInstanceId",
                  "Value": "{{instanceId}}"
              }
          ]
        }
    },
    {
      "name": "shouldShareImage",
      "action": "aws:branch",
      "isEnd": true,
      "inputs": {
        "Choices": [
          {
            "NextStep": "shareImage",
            "Variable": "{{shareImage}}",
            "BooleanEquals": true
          }
        ]
      }
    },
    {
      "name": "shareImage",
      "action": "aws:executeAwsApi",
      "isCritical": false,
      "inputs": {
        "Service": "ec2",
        "Api": "ModifyImageAttribute",
        "ImageId": "{{createImage.ImageId}}",
        "Attribute": "launchPermission",
        "OperationType": "add",
        "UserIds": ["{{accountIds}}"]
      },
      "isEnd": true
    }
  ],
  "outputs": [
    "createImage.ImageId"
  ]
}
DOC
}


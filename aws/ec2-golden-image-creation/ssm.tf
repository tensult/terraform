

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
    "platform": {
      "type": "String",
      "description": "Operating system platform",
      "default": "windows",
      "allowedValues": ["windows", "linux"]
    },
    "accountIds": {
      "type": "StringList",
      "description": "Account Ids to share image (AMI)",
      "default": ${jsonencode(var.account_ids)}
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
      "outputs": [{
        "Name": "osType",
        "Selector": "$.InstanceInformationList[0].PlatformName",
        "Type": "String"
      }, 
      {
        "Name": "osVersion",
        "Selector": "$.InstanceInformationList[0].PlatformVersion",
        "Type": "String"
      }
      ]
    },
    {
      "name": "prepareInstance",
      "action": "aws:branch",
      "inputs": {
        "Choices": [{
          "NextStep": "runSysprepForWindows",
          "Variable": "{{platform}}",
          "StringEquals": "windows"
        }],
        "Default": "createImage"
      }
    },
    {
      "name": "runSysprepForWindows",
      "action": "aws:runCommand",
      "inputs": {
        "DocumentName": "AWSEC2-RunSysprep",
        "InstanceIds": [
          "{{instanceId}}"
        ]
      },
      "nextStep": "waitForSysprep"
    },
    {
      "name": "waitForSysprep",
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
        "ImageName": "{{ describeInstance.osType }}"
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
      "name": "shareImage",
      "action": "aws:executeAwsApi",
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
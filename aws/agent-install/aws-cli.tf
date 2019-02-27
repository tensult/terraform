resource "aws_ssm_document" "windows_awscli" {
  name          = "Install_AWSCLI_windows"
  document_type = "Command"

  content = <<DOC
  {
     "schemaVersion": "2.2",
     "description": "Run a script to securely install Agent in Windows 2012 instance",
     "mainSteps": [
        {
            "action":"aws:runPowerShellScript",
            "name": "downloadAWSCLI",
            "inputs":{
               "runCommand":[
                  "mkdir 'C:\\Temp'\n",
                  "Invoke-WebRequest -Uri \"https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi\" -OutFile 'C:\\Temp\\AWS_CLI.msi'\n",
                  "dir 'C:\\Temp\\'\n",
                  "echo 'AWS CLI is downloaded.'"
               ]
            }
        },
        {
           "action": "aws:applications",
           "name": "installApplication",
           "inputs": {
              "parameters": "/quiet",
              "action": "Install",
              "source": "C:\\Temp\\AWS_CLI.msi"
            }
         },
         {
            "action":"aws:runPowerShellScript",
            "name": "waitForAWSCLI",
            "inputs":{
               "runCommand":[
                  "while (!(Test-Path 'C:\\Program Files\\Amazon\\AWSCLI\\bin\\aws.cmd')){ Wait-Event -Timeout 10}\n",
                  "& 'C:\\Program Files\\Amazon\\AWSCLI\\bin\\aws.cmd'\n",
                  "echo 'AWS CLI is installed.'\n",
                  "Remove-Item -Path 'C:\\Temp\\AWS_CLI.msi'\n",
                  "Restart-Computer -Force"
               ]
            }
         }
      ]
   }
DOC
}
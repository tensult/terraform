resource "aws_ssm_document" "windows_awscli" {
  name          = "Install_AWSCLI_windows"
  document_type = "Command"

  content = <<DOC
  {
     "schemaVersion": "2.2",
     "description": "Run a script to securely install Agent in Windows 2012 instance",
     "mainSteps": [
        {
           "action": "aws:applications",
           "name": "installApplication",
           "inputs": {
              "parameters": "/quiet",
              "action": "Install",
              "source": "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi"
            }
         },
         {
            "action":"aws:runPowerShellScript",
            "name": "waitForAWSCLI",
            "inputs":{
               "runCommand":[
                  "while (!(Test-Path 'C:\\Program Files\\Amazon\\AWSCLI\\bin\\aws.cmd')){ Wait-Event -Timeout 10}\n",
                  "& 'C:\\Program Files\\Amazon\\AWSCLI\\bin\\aws.cmd'\n",
                  "echo 'AWS CLI is installed.'"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "snow_agent_windows" {
  name          = "Snow_Agent_Windows"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a PowerShell script to securely to install Snow Agent for Windows instance",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellWithSecureString",
            "inputs":{
               "runCommand":[
                  "aws s3 cp '${var.url_snow_agent_windows}' 'C:\\Users\\Administrator\\windows_snowagent.msi'\n",
                  "msiexec /i 'C:\\Users\\Administrator\\windows_snowagent.msi' /l* 'C:\\Users\\Administrator\\snowinstall.log' /qn\n",
                  "Remove-Item -path 'C:\\Users\\Administrator\\windows_snowagent.msi' -recurse"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "sccm_agent_win2012" {
  name          = "SCCM_Agent_Windows2012"
  document_type = "Command"

  content = <<DOC
  {
  "schemaVersion": "2.2",
  "description": "Run a PowerShell script to securely to install SCCM Agent for Windows instance",
  "mainSteps": [
    {
      "action": "aws:runPowerShellScript",
      "name": "runPowerShellWithSecureString",
      "inputs": {
        "runCommand": [
          "aws s3 cp '${var.url_sccm_agent_windows}' 'C:\\Users\\Administrator\\'\n",
          "$sccm = 'C:\\Users\\Administrator\\Sccm-2016-New-Client.zip'\n",
          "Add-Type -AssemblyName System.IO.Compression.FileSystem\n",
          "[System.IO.Compression.ZipFile]::ExtractToDirectory($sccm,'C:\\Users\\Administrator\\SCCM\\')\n",
          "cd 'C:\\Users\\Administrator\\SCCM\\Sccm-2016-New-Client\\CLIENT\\'\n",
          ".\\ccmsetup SMSMP=${var.sccm_server} SMSSITECODE=${var.sitecode}\n",
          ".\\ccmsetup.exe /usepkicert smsmp=${var.sccm_server} ccmhostname=${var.sccm_server} smssitecode=${var.sitecode}\n"
        ]
      }
    }
  ]
}
DOC
}

resource "aws_ssm_document" "sccm_agent_win2016" {
  name          = "SCCM_Agent_Windows2016"
  document_type = "Command"

  content = <<DOC
  {
  "schemaVersion": "2.2",
  "description": "Run a PowerShell script to securely to install SCCM Agent for Windows instance",
  "mainSteps": [
    {
      "action": "aws:runPowerShellScript",
      "name": "runPowerShellWithSecureString",
      "inputs": {
        "runCommand": [
          "aws s3 cp '${var.url_sccm_agent_windows}' 'C:\\Users\\Administrator\\'\n",
          "$sccm = 'C:\\Users\\Administrator\\Sccm-2016-New-Client.zip'\n",
          "Expand-Archive -Path '$sccm' -DestinationPath 'C:\\Users\\Administrator\\SCCM\\'\n",
          "cd 'C:\\Users\\Administrator\\SCCM\\Sccm-2016-New-Client\\CLIENT\\'\n",
          ".\\ccmsetup SMSMP=${var.sccm_server} SMSSITECODE=${var.sitecode}\n",
          ".\\ccmsetup.exe /usepkicert smsmp=${var.sccm_server} ccmhostname=${var.sccm_server} smssitecode=${var.sitecode}\n"
        ]
      }
    }
  ]
}
DOC
}

resource "aws_ssm_document" "scom_agent_windows" {
  name          = "SCOM_Agent_Windows"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a PowerShell script to securely to install SCOM Agent for Windows instance",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellWithSecureString",
            "inputs":{
               "runCommand":[
                  "aws s3 cp '${var.url_scom_agent_windows}' 'C:\\Users\\Administrator\\windows_scomagent.msi'\n",
                  "msiexec.exe /i 'C:\\Users\\Administrator\\windows_scomagent.msi' /l*v 'C:\\Users\\Administrator\\MOMAgentinstall.log' USE_SETTINGS_FROM_AD=0 USE_MANUALLY_SPECIFIED_SETTINGS=1 MANAGEMENT_GROUP=Mphasis-Opsmgr MANAGEMENT_SERVER_DNS=SRVBAN19SMMSPH2 ACTIONS_USE_COMPUTER_ACCOUNT=1 AcceptEndUserLicenseAgreement=1 /qn\n",
                  "Remove-Item -path 'C:\\Users\\Administrator\\windows_scomagent.msi' -recurse"
               ]
            }
         }
      ]
   }
DOC
}

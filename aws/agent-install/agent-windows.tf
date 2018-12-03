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
                  "while (!(Get-Command 'aws' -errorAction SilentlyContinue)){ Wait-Event -Timeout 10}"
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

resource "aws_ssm_document" "sccm_agent_windows" {
  name          = "SCCM_Agent_Windows"
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
          "$sccm = 'C:\\Users\\Administrator\\Sccm-2016-New-Client.Zip'\n",
          "Add-Type -AssemblyName System.IO.Compression.FileSystem\n",
          "[System.IO.Compression.ZipFile]::ExtractToDirectory($sccm,'C:\\Users\\Administrator\\SCCM\\')\n",
          "$ccmpath = ('C:\\Users\\Administrator\\SCCM\\Sccm-2016-New-Client\\CLIENT\\')\n",
          "cd $ccmpath\n",
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

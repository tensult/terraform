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
                  "mkdir 'C:\\Temp\\'\n",
                  "aws s3 cp '${var.url_snow_agent_windows}' 'C:\\Temp\\windows_snowagent.msi'\n",
                  "msiexec /i 'C:\\Temp\\windows_snowagent.msi' /l* 'C:\\Temp\\snowinstall.log' /qn\n",
                  "Wait-Event -Timeout 90\n",
                  "Remove-Item -path 'C:\\Temp\\windows_snowagent.msi' -recurse"
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
                 "mkdir 'C:\\Temp\\'\n",
                 "aws s3 cp '${var.url_sccm_agent_windows}' 'C:\\Temp\\'\n",
                 "$sccm = 'C:\\Temp\\Sccm-2016-New-Client.zip'\n",
                 "Add-Type -AssemblyName System.IO.Compression.FileSystem\n",
                 "[System.IO.Compression.ZipFile]::ExtractToDirectory($sccm,'C:\\Temp\\SCCM\\')\n",
                 "cd 'C:\\Temp\\SCCM\\Sccm-2016-New-Client\\CLIENT\\'\n",
                 ".\\ccmsetup SMSMP=${var.sccm_server} SMSSITECODE=${var.sitecode}\n",".\\ccmsetup.exe /usepkicert smsmp=${var.sccm_server} ccmhostname=${var.sccm_server} smssitecode=${var.sitecode}\n",
                 "Wait-Event -Timeout 90\n",
                 "Remove-Item -path $sccm -recurse\n",
                 "Remove-Item -path 'C:\\Temp\\SCCM' -recurse\n",
                 "Restart-Computer -Force"
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
                 "mkdir 'C:\\Temp\\'\n",
                 "aws s3 cp '${var.url_sccm_agent_windows}' 'C:\\Temp\\'\n",
                 "$sccm = 'C:\\Temp\\Sccm-2016-New-Client.zip'\n",
                 "Expand-Archive -Path $sccm -DestinationPath 'C:\\Temp\\SCCM\\'\n",
                 "cd 'C:\\Temp\\SCCM\\Sccm-2016-New-Client\\CLIENT\\'\n",
                 ".\\ccmsetup SMSMP=${var.sccm_server} SMSSITECODE=${var.sitecode}\n",
                 ".\\ccmsetup.exe /usepkicert smsmp=${var.sccm_server} ccmhostname=${var.sccm_server} smssitecode=${var.sitecode}\n",
                 "Wait-Event -Timeout 90\n",
                 "Remove-Item -path $sccm -recurse\n",
                 "Remove-Item -path 'C:\\Temp\\SCCM' -recurse\n",
                 "Restart-Computer -Force"
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
                  "msiexec.exe /i 'C:\\Users\\Administrator\\windows_scomagent.msi' /l*v 'C:\\Users\\Administrator\\MOMAgentinstall.log' USE_SETTINGS_FROM_AD=0 USE_MANUALLY_SPECIFIED_SETTINGS=1 MANAGEMENT_GROUP=${var.scom_management_group} MANAGEMENT_SERVER_DNS=SRVBAN19SMMSPH2 ACTIONS_USE_COMPUTER_ACCOUNT=1 AcceptEndUserLicenseAgreement=1 /qn\n",
                  "Remove-Item -path 'C:\\Users\\Administrator\\windows_scomagent.msi' -recurse"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "windows_awscli" {
  name          = "Install_AWSCLI_windows"
  document_type = "Command"

  content = <<DOC
  {
     "schemaVersion": "3.0",
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

resource "aws_ssm_document" "windows_powershell_6" {
  name          = "Install_PowerShell_Core_windows2012"
  document_type = "Command"

  content = <<DOC
  {
     "schemaVersion": "2.0",
     "description": "Run a script to securely install PowerShell Core in Windows 2012 instance",
     "mainSteps": [
        {
           "action": "aws:applications",
           "name": "installApplication",
           "inputs": {
              "parameters": "/quiet",
              "action": "Install",
              "source": "${var.url_powershell_6_windows}"
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
      "schemaVersion":"2.0",
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
  "schemaVersion": "2.0",
  "description": "Run a PowerShell script to securely to install SCCM Agent for Windows instance",
  "mainSteps": [
    {
      "action": "aws:runPowerShellScript",
      "name": "runPowerShellWithSecureString",
      "inputs": {
        "runCommand": [
          "aws s3 cp ${var.url_sccm_agent_windows} C:\\Users\\Administrator\\\n",
          "$sccm = 'C:\\Users\\Administrator\\Sccm-2016-New-Client.Zip'\n",
          "Add-Type -AssemblyName System.IO.Compression.FileSystem\n",
          "[System.IO.Compression.ZipFile]::ExtractToDirectory($sccm,'C:\\Users\\Administrator\\SCCM\\')\n",
          "$ccmpath = ('C:\\Users\\Administrator\\SCCM\\Sccm-2016-New-Client\\CLIENT\\')\n",
          "cd $ccmpath\n",
          ".\ccmsetup SMSMP=${var.sccm_server} SMSSITECODE=${var.sitecode}\n",
          ".\ccmsetup.exe /usepkicert smsmp=${var.sccm_server} ccmhostname=${var.sccm_server} smssitecode=${var.sitecode}\n"
        ]
      }
    }
  ]
}
DOC
}



resource "aws_ssm_document" "mcafee_agent_windows" {
  name          = "McAfee_Agent_Windows"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a PowerShell script to securely to install McAfee Agent for Windows instance",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellWithSecureString",
            "inputs":{
               "runCommand":[
                  "aws s3 cp '${var.url_mcafee_windows}' 'C:\\Temp\\'\n",
                  "$mcafee = ('C:\\Temp\\McAfee_Endpoint_Security_10_5_4_4035_15_stand_alone_client_install.Zip')\n",
                  "Add-Type -AssemblyName System.IO.Compression.FileSystem\n",
                  "[System.IO.Compression.ZipFile]::ExtractToDirectory($mcafee,'C:\\Temp\\McAfee\\)\n",
                  "$endpoint = ('C:\\Temp\\McAfee\\Endpoint Security Platform 10.5.4 Build 4214 Package #5 PATCH Repost (AAA-LICENSED-RELEASE-PATCH ).Zip’)\n",
                  "Expand-Archive -Path $endpoint -DestinationPath 'C:\\Temp\\McAfee\\EndpointSecurityPlatform10.5.4\\'\n",
                  "'C:\\Temp\\McAfee\\EndpointSecurityPlatform10.5.4\\setupCC.exe'\n",
                  "Wait-Event -Timeout 10\n",
                  "msiexec.exe /i 'C:\\Temp\\McAfee\\EndpointSecurityPlatform10.5.4\\McAfee_Common_x64.msi /l*v 'C:\\Temp\\logs\\McAfee_Common_x64.log' /qn\n",
                  "Wait-Event -Timeout 20\n",
                  "Remove-Item -path 'C:\\Temp\\McAfee\\EndpointSecurityPlatform10.5.4' -recurse\n",
                  "$firewall = ('C:\\Temp\\McAfee\\Firewall 10.5.4 Build 4179 Package #1 PATCH Repost (AAA-LICENSED-RELEASE-PATCH ).Zip')\n",
                  "Expand-Archive -Path $firewall -DestinationPath 'C:\\Temp\\McAfee\\Firewall10.5.4\\'\n",
                  "'C:\\Temp\\McAfee\\Firewall10.5.4\\setupFW.exe'\n",
                  "Wait-Event -Timeout 10\n",
                  "msiexec.exe /i 'C:\\Temp\\McAfee\\Firewall10.5.4\\McAfee_Firewall_x64.msi' /l*v 'C:\\Temp\\logs\\McAfee_Firewall.log' /qn\n",
                  "Wait-Event -Timeout 20\n",
                  "Remove-Item -path 'C:\\Temp\\McAfee\\Firewall10.5.4' -recurse\n",
                  "$threatTar = ('C:\\Temp\\McAfee\\Threat Prevention 10.5.4 Build 4240 Package #4 PATCH Repost (AAA-LICENSED-RELEASE-PATCH ).Zip')\n",
                  "Expand-Archive -Path $threatTar -DestinationPath 'C:\\Temp\\McAfee\\ThreatPrevention10.5.4\\'\n",
                  "'C:\\Temp\\McAfee\\ThreatPrevention10.5.4\\setupTP.exe'\n",
                  "Wait-Event -Timeout 10\n",
                  "msiexec.exe /i 'C:\\Temp\\McAfee\\ThreatPrevention10.5.4\\McAfee_Threat_Prevention_x64.msi' /l*v 'C:\\Temp\\logs\\McAfee_Threat_Prevention.log' /qn\n",
                  "Wait-Event -Timeout 20\n",
                  "Remove-Item -path 'C:\\Temp\\McAfee\\ThreatPrevention10.5.4' -recurse\n",
                  "$webcontrol = ('C:\\Temp\\McAfee\\Web Control 10.5.4 Build 4177 Package #1 PATCH Repost (AAA-LICENSED-RELEASE-PATCH ).Zip')\n",
                  "Expand-Archive -Path $webcontrol -DestinationPath 'C:\\Temp\\McAfee\\WebControl10.5.4\\'\n",
                  "'C:\\Temp\\McAfee\\WebControl10.5.4\\setupWC.exe'\n",
                  "Wait-Event -Timeout 10\n",
                  "msiexec.exe /i C:\\Temp\\McAfee\\WebControl10.5.4\\McAfee_Web_Control_x64.msi /l*v C:\\Temp\\logs\\webcontrol.log /qn\n",
                  "Wait-Event -Timeout 20\n",
                  "Remove-Item -path 'C:\\Temp\\McAfee\\WebControl10.5.4' -recurse\n",
                  "Remove-Item -path 'C:\\Temp\\McAfee' -recurse\n"
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
      "schemaVersion":"2.0",
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

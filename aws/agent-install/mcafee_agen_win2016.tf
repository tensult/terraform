resource "aws_ssm_document" "mcafee_agent_windows2016" {
  name          = "McAfee_Agent_Windows2016"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a PowerShell script to securely to install McAfee Agent for Windows instance",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"downloadmcafee",
            "inputs":{
               "runCommand":[
                  "mkdir 'C:\\Temp'\n",
                  "mkdir 'C:\\Temp\\logs'\n",
                  "aws s3 cp '${var.url_mcafee_windows}' 'C:\\Temp\\'\n",
                  "$mcafee = ('C:\\Temp\\McAfee_Endpoint_Security_10_5_4_4035_15_stand_alone_client_install.Zip')\n",
                  "Expand-Archive -Path $mcafee -DestinationPath 'C:\\Temp\\McAfee\\'\n",
                  "Wait-Event -Timeout 60\n",
                  "echo 'McAfee Downloaded Successfully'"
               ]
            }
         },
         {
            "action":"aws:runPowerShellScript",
            "name":"endpoint",
            "inputs":{
               "runCommand":[
                  "$endpoint = ('C:\\Temp\\McAfee\\Endpoint Security Platform 10.5.4 Build 4214 Package #5 PATCH Repost (AAA-LICENSED-RELEASE-PATCH ).Zip')\n",
                  "Wait-Event -Timeout 10\n",
                  "Expand-Archive -Path $endpoint -DestinationPath 'C:\\Temp\\McAfee\\EndpointSecurityPlatform10.5.4\\'\n",
                  "Wait-Event -Timeout 30\n",
                  "for ($i=0; $i -le 3; $i++) {Invoke-Expression 'C:\\Temp\\McAfee\\EndpointSecurityPlatform10.5.4\\setupCC.exe'}\n",
                  "Wait-Event -Timeout 300\n",
                  "msiexec.exe /i 'C:\\Temp\\McAfee\\EndpointSecurityPlatform10.5.4\\McAfee_Common_x64.msi' /l*v 'C:\\Temp\\logs\\McAfee_Common.log' /qn\n",
                  "Wait-Event -Timeout 300\n",
                  "echo 'Endpoint Security Installed Successfully'\n"
               ]
            }
         },
         {
            "action":"aws:runPowerShellScript",
            "name":"firewall",
            "inputs":{
               "runCommand":[
                  "$firewall = ('C:\\Temp\\McAfee\\Firewall 10.5.4 Build 4179 Package #1 PATCH Repost (AAA-LICENSED-RELEASE-PATCH ).Zip')\n",
                  "Wait-Event -Timeout 10\n",
                  "Expand-Archive -Path $firewall -DestinationPath 'C:\\Temp\\McAfee\\Firewall10.5.4\\'\n",
                  "Wait-Event -Timeout 30\n",
                  "for ($i=0; $i -le 3; $i++) {Invoke-Expression 'C:\\Temp\\McAfee\\Firewall10.5.4\\setupFW.exe'}\n",
                  "Wait-Event -Timeout 300\n",
                  "msiexec.exe /i 'C:\\Temp\\McAfee\\Firewall10.5.4\\McAfee_Firewall_x64.msi' /l*v 'C:\\Temp\\logs\\McAfee_Firewall.log' /qn\n",
                  "Wait-Event -Timeout 180\n",
                  "echo 'Firewall Installed Successfully'\n"
               ]
            }
         },
         {
            "action":"aws:runPowerShellScript",
            "name":"threatprevention",
            "inputs":{
               "runCommand":[
                  "$threat = ('C:\\Temp\\McAfee\\Threat Prevention 10.5.4 Build 4240 Package #4 PATCH Repost (AAA-LICENSED-RELEASE-PATCH ).Zip')\n",
                  "Wait-Event -Timeout 10\n",
                  "Expand-Archive -Path $threat -DestinationPath 'C:\\Temp\\McAfee\\ThreatPrevention10.5.4\\'\n",
                  "Wait-Event -Timeout 30\n",
                  "for ($i=0; $i -le 3; $i++) {Invoke-Expression 'C:\\Temp\\McAfee\\ThreatPrevention10.5.4\\setupTP.exe'}\n",
                  "Wait-Event -Timeout 300\n",
                  "msiexec.exe /i 'C:\\Temp\\McAfee\\ThreatPrevention10.5.4\\McAfee_Threat_Prevention_x64.msi' /l*v 'C:\\Temp\\logs\\McAfee_Threat_Prevention.log' /qn\n",
                  "Wait-Event -Timeout 180\n",
                  "echo 'Threat Prevention Installed Successfully'\n"
               ]
            }
         },
         {
            "action":"aws:runPowerShellScript",
            "name":"webcontrol",
            "inputs":{
               "runCommand":[
                  "$webcontrol = ('C:\\Temp\\McAfee\\Web Control 10.5.4 Build 4177 Package #1 PATCH Repost (AAA-LICENSED-RELEASE-PATCH ).Zip')\n",
                  "Wait-Event -Timeout 10\n",
                  "Expand-Archive -Path $webcontrol -DestinationPath 'C:\\Temp\\McAfee\\WebControl10.5.4\\'\n",
                  "Wait-Event -Timeout 30\n",
                  "for ($i=0; $i -le 3; $i++) {Invoke-Expression 'C:\\Temp\\McAfee\\WebControl10.5.4\\setupWC.exe'}\n",
                  "Wait-Event -Timeout 300\n",
                  "msiexec.exe /i 'C:\\Temp\\McAfee\\WebControl10.5.4\\McAfee_Web_Control_x64.msi' /l*v 'C:\\Temp\\logs\\webcontrol.log' /qn\n",
                  "Wait-Event -Timeout 300\n",
                  "echo 'Web Control Installed Successfully'\n"
               ]
            }
         },
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellWithSecureString",
            "inputs":{
               "runCommand":[
                  "Remove-Item -Path 'C:\\Temp\\McAfee' -recurse\n",
                  "$mcafee = ('C:\\Temp\\McAfee_Endpoint_Security_10_5_4_4035_15_stand_alone_client_install.Zip')\n",
                  "Remove-Item -Path $mcafee -recurse\n",
                  "Restart-Computer -Force"
               ]
            }
         }
      ]
   }
DOC
}

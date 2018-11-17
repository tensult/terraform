resource "aws_ssm_document" "av_update_automation" {
  name          = "Windows_Antivirus_Update_Automation"
  document_type = "Automation"

  content = "${file("windows_av_update_automation_document.json")}"
}

resource "aws_ssm_document" "av_update_run_command" {
  name          = "Windows_Antivirus_Update_Run_Command"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a PowerShell script to update Antivirus a Windows instance",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellWithSecureString",
            "inputs":{
               "runCommand":[
                  "& \"C:\Program Files\McAfee\Agent\cmdagent.exe\" -c\n",
                  "Start-Sleep -s 30"
               ]
            }
         }
      ]
   }
DOC
}


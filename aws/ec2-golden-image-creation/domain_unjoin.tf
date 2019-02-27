resource "aws_ssm_document" "windows_unjoin_domain" {
  name          = "Windows_Unjoin_Domain"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a PowerShell script to unjoin a Windows instance from the domain",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellWithSecureString",
            "inputs":{
               "runCommand":[
                  "$username = (Get-SSMParameterValue -Name /domain/username).Parameters[0].Value\n",
                  "$domain = (Get-SSMParameterValue -Name /domain/name).Parameters[0].Value\n",
                  "$domain_username = \"$domain\\$username\"\n",
                  "$password = (Get-SSMParameterValue -Name /domain/password -WithDecryption $True).Parameters[0].Value | ConvertTo-SecureString -asPlainText -Force\n",
                  "$credential = New-Object System.Management.Automation.PSCredential($domain_username,$password)\n",
                  "Remove-Computer -UnjoinDomaincredential $credential -WorkgroupName \"WORKGROUP\" -Force -PassThru -Verbose -Restart"
               ]
            }
         }
      ]
   }
DOC
}

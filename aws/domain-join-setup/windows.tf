resource "aws_ssm_document" "windows_2012" {
  name          = "Windows_2012_Domain_Join"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a PowerShell script to securely domain-join a Windows instance",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellWithSecureString",
            "inputs":{
               "runCommand":[
                  "$ipdns = (Get-SSMParameterValue -Name /domain/dns_ip).Parameters[0].Value\n",
                  "$domain = (Get-SSMParameterValue -Name /domain/name).Parameters[0].Value\n",
                  "$ouPath = (Get-SSMParameterValue -Name /domain/ou_path).Parameters[0].Value\n",
                  "$username = (Get-SSMParameterValue -Name /domain/username).Parameters[0].Value\n",
                  "$domain_username = \"$domain\\$username\"\n",
                  "$password = (Get-SSMParameterValue -Name /domain/password -WithDecryption $True).Parameters[0].Value | ConvertTo-SecureString -asPlainText -Force\n",
                  "$credential = New-Object System.Management.Automation.PSCredential($domain_username,$password)\n",
                  "Set-DnsClientServerAddress \"Ethernet 2\" -ServerAddresses ($ipdns)\n",
                  "Add-Computer -DomainName $domain -OUPath \"$ouPath\" -Credential $credential\n",
                  "Restart-Computer -Force"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "windows_2016" {
  name          = "Windows_2016_Domain_Join"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a PowerShell script to securely domain-join a Windows instance",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellWithSecureString",
            "inputs":{
               "runCommand":[
                  "$ipdns = (Get-SSMParameterValue -Name /domain/dns_ip).Parameters[0].Value\n",
                  "$domain = (Get-SSMParameterValue -Name /domain/name).Parameters[0].Value\n",
                  "$ouPath = (Get-SSMParameterValue -Name /domain/ou_path).Parameters[0].Value\n",
                  "$username = (Get-SSMParameterValue -Name /domain/username).Parameters[0].Value\n",
                  "$domain_username = \"$domain\\$username\"\n",
                  "echo $domain_username\n",
                  "$password = (Get-SSMParameterValue -Name /domain/password -WithDecryption $True).Parameters[0].Value | ConvertTo-SecureString -asPlainText -Force\n",
                  "$credential = New-Object System.Management.Automation.PSCredential($domain_username,$password)\n",
                  "Set-DnsClientServerAddress \"Ethernet\" -ServerAddresses $ipdns\n",
                  "Add-Computer -DomainName $domain -OUPath \"$ouPath\" -Credential $credential\n",
                  "Restart-Computer -Force"
               ]
            }
         }
      ]
   }
DOC
}




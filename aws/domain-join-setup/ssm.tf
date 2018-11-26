data "aws_kms_key" "ssm" {
  key_id = "alias/ssm-key"
}

resource "aws_ssm_parameter" "domain_username" {
  name  = "/domain/username"
  description  = "Domain username"
  type  = "String"
  value = "${var.domain_username}"
  overwrite = true
}

resource "aws_ssm_parameter" "domain_password" {
  name  = "/domain/password"
  description  = "Domain password"
  type  = "SecureString"
  value = "${var.domain_password}"
  key_id = "${data.aws_kms_key.ssm.arn}"
  overwrite = true
}

resource "aws_ssm_parameter" "ipdns" {
  name  = "/domain/dns_ip"
  description  = "DNS IP Address"
  type  = "String"
  value = "${join(",", var.domain_dns_ips)}"
  overwrite = true
}

resource "aws_ssm_parameter" "domain_name" {
  name  = "/domain/name"
  description  = "Domain name"
  type  = "String"
  value = "${var.domain_name}"
  overwrite = true
}

resource "aws_ssm_parameter" "domain_ou_path" {
  name  = "/domain/ou_path"
  description  = "Domain OU path"
  type  = "String"
  value = "${var.domain_ou_path}"
  overwrite = true
}


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
  
resource "aws_ssm_document" "redhatlinux" {
  name          = "RedHat_CentOS_Domain_Join"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a Shell script to securely domain-join a RedHat and CentOS instance",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                  "domain=$(aws ssm get-parameters --names /domain/name --region ap-south-1 --query 'Parameters[0].Value' --output text)\n",
                  "ouPath=$(aws ssm get-parameters --names /domain/ou_path --region ap-south-1 --query 'Parameters[0].Value' --output text)\n",
                  "username=$(aws ssm get-parameters --names /domain/username --region ap-south-1 --query 'Parameters[0].Value' --output text)\n",
                  "password=$(aws ssm get-parameters --names /domain/password --with-decryption --region ap-south-1 --query 'Parameters[0].Value' --output text)\n",
                  "for i in 1 2 3 4 5;\n",
                  "do\n",
                  "echo $password | sudo realm join --membership-software=adcli -U $username --computer-ou=$ouPath $domain && echo \"Host has joined domain successfully after $i retries\" && break;\n",
                  "done\n",
                  "if ! sudo realm list |grep $domain; then echo \"Host has not joined $domain so exiting\"; exit -1; fi;\n",
                  "sudo su -\n",
                  "cp /etc/sssd/sssd.conf /etc/sssd/sssd.conf.backup\n",
                  "echo dyndns_update = true >> /etc/sssd/sssd.conf\n",
                  "echo dyndns_refresh_interval = 43200 >> /etc/sssd/sssd.conf\n",
                  "echo dyndns_update_ptr = true >> /etc/sssd/sssd.conf\n",
                  "echo dyndns_ttl = 3600 >> /etc/sssd/sssd.conf\n",
                  "echo Updated sssd.conf, now restarting sssd service\n",
                  "/bin/systemctl restart sssd.service\n",
                  "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup\n",
                  "sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config\n",
                  "echo Updated sshd_config, now restarting sshd service\n",
                  "/bin/systemctl restart sshd.service\n",
                  "echo 'CIOCloudmanagement@corp.mphasis.com ALL=(ALL) ALL' >> /etc/sudoers.d/CIOCloudmanagement\n",
                  "sudo shutdown -r 1"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "linux" {
  name          = "Ubuntu_Amzlinux_Domain_Join"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a Shell script to securely domain-join a Ubuntu and Amazon Linux instances",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                  "domain=$(aws ssm get-parameters --names /domain/name --region ap-south-1 --query 'Parameters[0].Value' --output text)\n",
                  "ouPath=$(aws ssm get-parameters --names /domain/ou_path --region ap-south-1 --query 'Parameters[0].Value' --output text)\n",
                  "username=$(aws ssm get-parameters --names /domain/username --region ap-south-1 --query 'Parameters[0].Value' --output text)\n",
                  "password=$(aws ssm get-parameters --names /domain/password --with-decryption --region ap-south-1 --query 'Parameters[0].Value' --output text)\n",
                  "for i in 1 2 3 4 5;\n",
                  "do\n",
                  "echo $password | sudo realm join --membership-software=samba -U $username --computer-ou=$ouPath $domain && echo \"Host has joined domain successfully after $i retries\" && break;\n",
                  "done\n",
                  "if ! sudo realm list |grep $domain; then echo \"Host has not joined $domain so exiting\"; exit -1; fi;\n",
                  "sudo su -\n",
                  "cp /etc/sssd/sssd.conf /etc/sssd/sssd.conf.backup\n",
                  "echo dyndns_update = true >> /etc/sssd/sssd.conf\n",
                  "echo dyndns_refresh_interval = 43200 >> /etc/sssd/sssd.conf\n",
                  "echo dyndns_update_ptr = true >> /etc/sssd/sssd.conf\n",
                  "echo dyndns_ttl = 3600 >> /etc/sssd/sssd.conf\n",
                  "echo Updated sssd.conf, now restarting sssd service\n",
                  "/bin/systemctl restart sssd.service\n",
                  "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup\n",
                  "sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config\n",
                  "echo Updated sshd_config, now restarting sshd service\n",
                  "/bin/systemctl restart sshd.service\n",
                  "echo 'CIOCloudmanagement@corp.mphasis.com ALL=(ALL) ALL' >> /etc/sudoers.d/CIOCloudmanagement\n",
                  "sudo shutdown -r 1"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "Hostname_Windows" {
  name          = "Hostname_Change_Windows"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a Shell script to securely Changing the hostname for Windows instance",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellScript",
            "inputs":{
               "runCommand":[
               "$currenthostname = hostname\n",
               "$instanceId = ((Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/instance-id -UseBasicParsing).Content)\n",
               "$newhostname = (aws ec2 describe-instances --instance-id $instanceId --region ap-south-1 --query 'Reservations[0].Instances[0].Tags[?Key==`hostname`].Value' --output text)\n",
               "Rename-computer –computername \"$currenthostname\" –newname \"$newhostname\"\n",
               "Restart-Computer -Force"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "Hostname_Linux" {
  name          = "Hostname_Change_Linux"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a Shell script to securely Changing the hostname for Linux instance",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                  "sudo su -",
                  "domain=$(aws ssm get-parameters --names /domain/name --region ap-south-1 --query 'Parameters[0].Value' --output text)\n",
                  "if realm list |grep $domain; then echo \"Host has already joined $domain so exiting\"; exit -1; fi;\n",
                  "instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)\n",
                  "hostname=$(aws ec2 describe-instances --instance-id $instanceId --region ap-south-1 --query 'Reservations[0].Instances[0].Tags[?Key==`hostname`].Value' --output text)\n",
                  "if [ -z \"$hostname\" ]; then echo \"hostname (case sensitive) tag is not defined so exiting\"; exit -1; fi\n",
                  "echo $hostname.$domain > /etc/hostname\n",
                  "echo 127.0.0.1 $hostname.$domain $hostname > /etc/hosts\n",
                  "echo \"Hostname has changed and rebooting now\"\n",
                  "reboot"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "Hostname_Ubuntu" {
  name          = "Hostname_Change_Ubuntu"
  document_type = "Command"
  
  content = <<DOC
  {
   "schemaVersion":"2.0",
   "description":"Run a Shell script to securely Changing the hostname for Ubuntu instance",
   "mainSteps":[
      {
         "action":"aws:runShellScript",
         "name":"runShellScript",
         "inputs":{
            "runCommand":[
               "sudo su -",
               "domain=$(aws ssm get-parameters --names /domain/name --region ap-south-1 --query 'Parameters[0].Value' --output text)\n",
               "if realm list |grep $domain; then echo \"Host has already joined $domain so exiting\"; exit -1; fi;\n",
               "instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)\n",
               "hostname=$(aws ec2 describe-instances --instance-id $instanceId --region ap-south-1 --query 'Reservations[0].Instances[0].Tags[?Key==`hostname`].Value' --output text)\n",
               "ipv4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)\n",
               "if [ -z \"$hostname\" ]; then echo \"hostname (case sensitive) tag is not defined so exiting\"; exit -1; fi\n",
               "echo $hostname.$domain > /etc/hostname\n",
               "echo 127.0.0.1 $hostname.$domain > /etc/hosts\n",
               "echo \"$ipv4 $hostname\" >> /etc/hosts\n",
               "echo \"Hostname has changed and rebooting now\"\n",
               "reboot"
            ]
         }
      }
   ]
}
DOC
}

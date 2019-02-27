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
                  "echo \"CIOCloudmanagement@$domain ALL=(ALL) ALL\"
                   >> /etc/sudoers.d/CIOCloudmanagement\n",
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
                  "echo \"CIOCloudmanagement@$domain ALL=(ALL) ALL\" >> /etc/sudoers.d/CIOCloudmanagement\n",
                  "sudo shutdown -r 1"
               ]
            }
         }
      ]
   }
DOC
}

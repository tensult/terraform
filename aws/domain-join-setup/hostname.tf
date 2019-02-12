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
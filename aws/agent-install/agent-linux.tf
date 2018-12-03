resource "aws_ssm_document" "mcafee_redhat" {
  name          = "McAfee_Agent_RedHat"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a Shell script to install McAfee Agent in RedHat instance",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                   "sudo su -\n",
                   "yum install zip unzip -y\n",
                   "aws s3 cp ${var.url_mcafee_redhat} /opt/mcafee_redhat_installrpm.sh\n",
                   "chmod +x /opt/mcafee_redhat_installrpm.sh\n",
                   "/opt/mcafee_redhat_installrpm.sh -i\n",
                   "rm -rf /opt/mcafee_redhat_installrpm.sh\n",
                   "exit\n",
                   "echo McAfee Agent Installed Successfully"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "snow_redhat" {
  name          = "Snow_Agent_RedHat"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a Shell script to install Snowsoft Agent in RedHat instance",
      "mainSteps":[
        {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                   "sudo su -\n",
                   "aws s3 cp ${var.url_snow_redhat} /opt/snowagent_redhat.rpm\n",
                   "rpm -i /opt/snowagent_redhat.rpm\n",
                   "rm -rf /opt/snowagent_redhat.rpm\n",
                   "exit\n",
                   "echo Snow Agent Installed Successfully"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "mcafee_centos" {
  name          = "McAfee_Agent_CentOS"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a Shell script to install McAfee Agent in CentOS instance",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                   "sudo su -\n",
                   "yum install zip unzip -y\n",
                   "aws s3 cp ${var.url_mcafee_centos} /opt/mcafee_centos_installrpm.sh\n",
                   "chmod +x /opt/mcafee_centos_installrpm.sh\n",
                   "/opt/mcafee_centos_installrpm.sh -i\n",
                   "rm -rf /opt/mcafee_centos_installrpm.sh\n",
                   "exit\n",
                   "echo McAfee Agent Installed Successfully"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "snow_centos" {
  name          = "Snow_Agent_CentOS"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a Shell script to install Snowsoft Agent in CentOS instance",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                   "sudo su -\n",
                   "aws s3 cp ${var.url_snow_centos} /opt/snowagent_centos.rpm\n",
                   "rpm -i /opt/snowagent_centos.rpm\n",
                   "rm -rf /opt/snowagent_centos.rpm\n",
                   "exit\n",
                   "echo Snow Agent Installed Successfully"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "mcafee_amzlinux" {
  name          = "McAfee_Agent_AmzLinux"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a Shell script to install McAfee Agent in Amazon Linux instance",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                   "sudo su -\n",
                   "yum install zip unzip -y\n",
                   "aws s3 cp ${var.url_mcafee_amzlinux} /opt/mcafee_amzlinux_installrpm.sh\n",
                   "chmod +x /opt/mcafee_amzlinux_installrpm.sh\n",
                   "/opt/mcafee_amzlinux_installrpm.sh -i\n",
                   "rm -rf /opt/mcafee_amzlinux_installrpm.sh\n",
                   "exit\n",
                   "echo McAfee Agent Installed Successfully"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "snow_amzlinux" {
  name          = "Snow_Agent_AmzLinux"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a Shell script to install Snowsoft Agent in Amazon Linux instance",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                   "sudo su -\n",
                   "aws s3 cp ${var.url_snow_amzlinux} /opt/snowagent_amzlinux.rpm\n",
                   "rpm -i /opt/snowagent_amzlinux.rpm\n",
                   "rm -rf /opt/snowagent_amzlinux.rpm\n",
                   "exit\n",
                   "echo Snow Agent Installed Successfully"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "mcafee_ubuntu" {
  name          = "McAfee_Agent_Ubuntu"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a Shell script to install McAfee Agent in Ubuntu instance",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                   "sudo su -\n",
                   "apt-get install zip unzip -y\n",
                   "aws s3 cp ${var.url_mcafee_ubuntu} /opt/mcafee_ubuntu_installdeb.sh\n",
                   "chmod +x /opt/mcafee_ubuntu_installdeb.sh\n",
                   "/opt/mcafee_ubuntu_installdeb.sh -i\n",
                   "rm -rf /opt/mcafee_ubuntu_installdeb.sh\n",
                   "exit\n",
                   "echo McAfee Agent Installed Successfully"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "snow_ubuntu" {
  name          = "Snow_Agent_Ubuntu"
  document_type = "Command"
  
  content = <<DOC
  {
      "schemaVersion":"2.2",
      "description":"Run a Shell script to install Snowsoft Agent in Ubuntu instance",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                   "sudo su -\n",
                   "aws s3 cp ${var.url_snow_ubuntu} /opt/snowagent_ubuntu.deb\n",
                   "dpkg -i /opt/snowagent_ubuntu.deb\n",
                   "rm -rf /opt/snowagent_ubuntu.deb\n",
                   "exit\n",
                   "echo Snow Agent Installed Successfully"
               ]
            }
         }
      ]
   }
DOC
}
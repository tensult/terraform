resource "aws_ssm_document" "tomcat" {
  name          = "Install_Tomcat"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a Shell script to securely install the Tomcat on CentOS",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
               "runCommand":[
                   "sudo su -\n",
                   "yum install java-1.7.0-openjdk-devel -y\n",
                   "groupadd tomcat\n",
                   "useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat\n",
                   "cd ~\n",
                   "yum install wget vim -y\n",
                   "wget http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.tar.gz\n",
                   "mkdir /opt/tomcat\n",
                   "tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1\n",
                   "cd /opt/tomcat\n",
                   "chgrp -R tomcat /opt/tomcat\n",
                   "chmod -R g+r conf\n",
                   "chmod g+x conf\n",
                   "chown -R tomcat webapps/ work/ temp/ logs/\n",
                   "wget ${var.tomcat_file}\n",
                   "cp tomcat.service.txt /etc/systemd/system/tomcat.service\n",
                   "systemctl daemon-reload\n",
                   "systemctl start tomcat\n",
                   "systemctl enable tomcat\n",
                   "exit"
               ]
            }
         }
      ]
  }
DOC
}
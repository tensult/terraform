resource "aws_ssm_document" "Domainjoin_Dependencies_Linux" {
  name          = "Domainjoin_Dependencies_Linux"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a Shell script to securely install the dependencies for domain join",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellScript",
            "inputs":{
               "runCommand":[
                   "sudo su -\n",
                    "yum update -y\n",
                    "curl -O https://bootstrap.pypa.io/get-pip.py\n",
                    "python get-pip.py\n",
                    "pip install awscli\n",
                    "yum install sssd realmd oddjob oddjob-mkhomedir samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python -y\n",
                    "echo Packages are installed"
               ]
            }
         }
      ]
   }
DOC
}

resource "aws_ssm_document" "Domainjoin_Dependencies_Ubuntu" {
  name          = "Domainjoin_Dependencies_Ubuntu"
  document_type = "Command"

  content = <<DOC
  {
      "schemaVersion":"2.0",
      "description":"Run a Shell script to securely install the dependencies for domain join",
      "mainSteps":[
         {
            "action":"aws:runPowerShellScript",
            "name":"runPowerShellScript",
            "inputs":{
               "runCommand":[
                    "sudo su -\n",
                    "apt-get update -y\n",
                    "curl -O https://bootstrap.pypa.io/get-pip.py\n",
                    "python get-pip.py\n",
                    "pip install awscli\n",
                    "apt-get install sssd realmd krb5-user packagekit oddjob oddjob-mkhomedir samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python -y\n",
                    "echo Packages are installed"
               ]
            }
         }
      ]
   }
DOC
}
## Creaitng ALB and Attach SSL certificate to ALB

This Terraform script is to create ELB and attach SSL certficate with this

Here the setp to Deploy in our enviourment

### Step 1: Edit var.tfvars variables
profile = Enter your profile name</br>
region = Enter region where you want to apply it</br>
env = Enter Enviourment Name, it show in the ALB tags</br> 
vpc_id = Enter Vpc Id to select vpc</br>
subnet_id = Enter Subnets Id eg: subnet-00ca3d68</br>
cer_arn = Enter your certificate arn</br>

### Step 2: terraform plan
` terraform plan -var-file=var.tfvars `

### Step 3: terraform apply

` terraform apply -var-file=var.tfvars `

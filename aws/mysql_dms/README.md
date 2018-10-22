### RDS MySQL Cross region & Cross account replication using DMS
 This project is used to automate the setting up of a DMS task for cross account cross region Data Migraion services. Before running the "main.tf" file please make sure to go through the "variables.tf" file so that all the required variables have been correctly defned. After doing so you can run the "main.tf" file with the following commands. First initialise Terraform with the following command:
```
terraform init
```
After initialisation has been done, you can proceed to running the "main.tf" file with the following command:
```
terraform apply
```
It creates a VPC for the DMS instance and the target DB in the region you want. It then sets up the VPC peering connection between the source and the target VPC's. It adds the routes for the VPC peering connection in the source and target. After this, it configures the DMS replication instance, defines the endpoints and then sets up the task. The security groups are also configured in both the source and the target so that they can communicate via their ports. 
### Note: 
When running the "main.tf" file you might get an error saying that the subnet_group ( for RDS and DMS) does not exist. In this case just run it again using " terraform apply" and you will be able to get the output.


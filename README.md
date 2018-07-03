# terraform
[WIP]Terraform automation scripts
## AWS
### Three tier
Three tier is industry standard for modern web application where we have 3 tiers for following
* Presentation tier (WebAPP tier): Prepares HTMLs by calling App tier
* Application tier (App tier): Prepare data by calling DB or other third party services
* Database tier (DB tier): Stores the data in database.

Creating three architecture in AWS requires lot of resources like VPC, Subnets, Gateways, Routing tables etc to be created and this has been automated using terraform, for details go [here](https://github.com/tensult/terraform/blob/master/aws/three-tier/README.md).

### MySQL Cross account, cross region DMS

Cross region replication helps to quickly recover from AWS region wide failures. Also it will help to serve the customer faster as we can use replica for read traffic and few of them might be closer to replica’s region.

Cross account replication helps to recover data from replication account when our master AWS account is compromised and we have lost access to the account completely. Such incidents happened in the past where one of the AWS customer account got hacked and the attacker deleted all the data. AWS provides several mechanisms to protect the data but having separate backup account with very limited access and tighter controls will help in unforeseen circumstances.

You can click on the following links to get a better understanding about DMS.
1. [Architecture](https://medium.com/tensult/cross-account-and-cross-region-rds-mysql-db-replication-part-1-55d307c7ae65)
2.  [Implementation](https://medium.com/tensult/cross-account-and-cross-region-rds-mysql-db-replication-part-1-55d307c7ae65) 

Please make sure to go through the readme files of each implementation so that the code wll give you the desired output. There is a "main.tf" file which configures the AWS environment while the "variables.tf" file is used to define the variables such as CIDR blocks, names, tags etc for the corresponding AWS resources. This is still a work in progress so feel free to reach out in case something is missing.


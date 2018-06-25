# terraform
[WIP]Terraform automation scripts
## AWS
### Three tier
Three tier is industry standard for modern web application where we have 3 tiers for following
* Presentation tier (WebAPP tier): Prepares HTMLs by calling App tier
* Application tier (App tier): Prepare data by calling DB or other third party services
* Database tier (DB tier): Stores the data in database.

Creating three architecture in AWS requires lot of resources like VPC, Subnets, Gateways, Routing tables etc to be created and this has been automated using terraform, for details go [here](https://github.com/tensult/terraform/blob/master/aws/three-tier/README.md).

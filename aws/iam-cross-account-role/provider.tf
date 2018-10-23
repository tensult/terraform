# Define AWS as our provider
provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::304943532825:role/Payer_to_DemoPOC"
    
  }
  region = "ap-south-1"
  profile = "master"
}
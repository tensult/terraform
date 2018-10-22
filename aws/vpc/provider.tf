# Define AWS as our provider
provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::207438937278:role/Demo" #Cross account role with main
    
  }
  region = "${var.aws_region}"
  profile = "main"

}

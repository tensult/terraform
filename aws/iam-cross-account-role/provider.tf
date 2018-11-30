# Define AWS as our provider
provider "aws" {
  region = "ap-south-1"
  profile = "${var.profile}"
}
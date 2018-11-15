# Define AWS as our provider
provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "tfstates"
    key    = "demoeuro/vpc"
    region = "eu-west-1"
  }
}

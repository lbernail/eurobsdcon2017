provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "tfstates"
    key    = "demoeuro/consul"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "tfstates"
    key    = "demoeuro/vpc"
    region = "eu-west-1"
  }
}

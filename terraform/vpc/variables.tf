variable "region" {}

variable "azs" {
  type = "map"

  default = {
    "eu-west-1" = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  }
}

variable "cidr_block" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "subnet_bits" {
  type    = "string"
  default = "8"
}

variable "subnet_prv_offset" {
  type    = "string"
  default = "128"
}

variable "vpc_name" {
  type    = "string"
  default = "Terraform VPC"
}

variable "vpc_short_name" {
  type    = "string"
  default = "terarform-vpc"
}

### Security group variables

variable "trusted_networks" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

### Bastion variables

variable "ami_data" {
  type = "map"

  default = {
    owner = "360116137065"
    name  = "openbsd-6.*-amd64-*"
  }
}

variable "bastion_instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "key_name" {
  type = "string"
}

variable "bastion_name" {
  type    = "string"
  default = "bastion"
}

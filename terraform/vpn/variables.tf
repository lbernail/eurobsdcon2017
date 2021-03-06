variable "region" {}

variable "ami_data" {
  type = "map"

  default = {
    owner = "360116137065"
    name  = "openbsd-6.*-amd64-*"
  }
}

variable "server_type" {
  type    = "string"
  default = "t2.micro"
}

variable "ip_offset" {
  type    = "string"
  default = "10"
}

variable "key_name" {}
variable "eip" {}

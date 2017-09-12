variable "region" {}

variable "cluster_id" {
  type    = "string"
  default = "consul"
}

variable "consul_servers" {
  type = "string"
}

variable "cluster_name" {
  type    = "string"
  default = "Consul"
}

variable "ami_data" {
  type = "map"

  default = {
    owner = "360116137065"
    name  = "openbsd-6.*-amd64-*"
  }
}

variable "consul_server_type" {
  type    = "string"
  default = "t2.micro"
}

variable "agent_server_type" {
  type    = "string"
  default = "t2.nano"
}

variable "key_name" {}

variable "consul_servers_tcp" {
  type    = "list"
  default = ["8300", "8301", "8302"]
}

variable "consul_servers_udp" {
  type    = "list"
  default = ["8301", "8302"]
}

variable "consul_clients_tcp" {
  type    = "list"
  default = ["8500", "8600"]
}

variable "consul_clients_udp" {
  type    = "list"
  default = ["8600"]
}

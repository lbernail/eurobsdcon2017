data "aws_ami" "consul" {
  most_recent = true

  filter {
    name   = "name"
    values = "${list(var.ami_data["name"])}"
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = "${list(var.ami_data["owner"])}"
}

resource "aws_security_group" "consul_client" {
  name        = "${var.cluster_id}-client"
  description = "Client accessing consul"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags {
    Name = "${var.cluster_name} Client"
  }
}

resource "aws_security_group" "consul" {
  name        = "${var.cluster_id}-servers"
  description = "Consul internal traffic"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags {
    Name = "${var.cluster_name} Servers"
  }
}

resource "aws_security_group_rule" "consul_servers_tcp" {
  count             = "${length(var.consul_servers_tcp)}"
  type              = "ingress"
  from_port         = "${var.consul_servers_tcp[count.index]}"
  to_port           = "${var.consul_servers_tcp[count.index]}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.consul.id}"
  self              = true
}

resource "aws_security_group_rule" "consul_servers_udp" {
  count             = "${length(var.consul_servers_udp)}"
  type              = "ingress"
  from_port         = "${var.consul_servers_udp[count.index]}"
  to_port           = "${var.consul_servers_udp[count.index]}"
  protocol          = "udp"
  security_group_id = "${aws_security_group.consul.id}"
  self              = true
}

resource "aws_security_group_rule" "consul_clients_tcp" {
  count                    = "${length(var.consul_clients_tcp)}"
  type                     = "ingress"
  from_port                = "${var.consul_clients_tcp[count.index]}"
  to_port                  = "${var.consul_clients_tcp[count.index]}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.consul.id}"
  source_security_group_id = "${aws_security_group.consul_client.id}"
}

resource "aws_security_group_rule" "consul_clients_udp" {
  count                    = "${length(var.consul_clients_udp)}"
  type                     = "ingress"
  from_port                = "${var.consul_clients_udp[count.index]}"
  to_port                  = "${var.consul_clients_udp[count.index]}"
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.consul.id}"
  source_security_group_id = "${aws_security_group.consul_client.id}"
}

resource "aws_security_group_rule" "consul_admin_tcp" {
  count                    = "${length(var.consul_clients_tcp)}"
  type                     = "ingress"
  from_port                = "${var.consul_clients_tcp[count.index]}"
  to_port                  = "${var.consul_clients_tcp[count.index]}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.consul.id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.sg_admin}"
}

resource "aws_security_group_rule" "consul_admin_udp" {
  count                    = "${length(var.consul_clients_udp)}"
  type                     = "ingress"
  from_port                = "${var.consul_clients_udp[count.index]}"
  to_port                  = "${var.consul_clients_udp[count.index]}"
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.consul.id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.sg_admin}"
}

resource "aws_instance" "consul" {
  ami                    = "${data.aws_ami.consul.id}"
  count                  = "${var.consul_servers}"
  instance_type          = "${var.consul_server_type}"
  key_name               = "${var.key_name}"
  subnet_id              = "${data.terraform_remote_state.vpc.private_subnets[count.index]}"
  vpc_security_group_ids = ["${list(data.terraform_remote_state.vpc.sg_ssh,aws_security_group.consul.id)}"]
  iam_instance_profile   = "${aws_iam_instance_profile.consul.name}"

  tags {
    Name = "${var.cluster_name} ${count.index}"
  }
}

#data "template_file" "consul_config" {
#  template = "${file("${path.module}/files/config_consul.tpl.sh")}"
#
#  vars {
#    TF_CONSUL_SERVERS = "${join(",",var.consul_servers)}"
#    TF_CONSUL_ROLE    = "server"
#    TF_CONSUL_OPTIONS = ""
#    TF_CONSUL_PUBLIC = "yes"
#  }
#}


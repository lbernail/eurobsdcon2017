data "aws_ami" "vpn" {
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

resource "aws_instance" "vpn" {
  ami                    = "${data.aws_ami.vpn.id}"
  instance_type          = "${var.server_type}"
  key_name               = "${var.key_name}"
  subnet_id              = "${data.terraform_remote_state.vpc.public_subnets[0]}"
  vpc_security_group_ids = ["${list(data.terraform_remote_state.vpc.sg_ssh,data.terraform_remote_state.consul.sg_consul_server)}"]
  iam_instance_profile   = "${data.terraform_remote_state.consul.consul_instance_profile}"
  user_data              = "${data.template_file.vpn_config.rendered}"

  tags {
    Name = "VPN server"
  }
}

data "template_file" "vpn_config" {
  template = "${file("${path.module}/files/config_vpn.tpl.sh")}"

  vars {
    TF_CONSUL_HOSTNAME   = "vpn"
    TF_CONSUL_SERVERS    = "0"
    TF_CONSUL_SERVERROLE = "false"
    TF_CONSUL_BIND_IP    = "127.0.0.1"
    TF_CONSUL_UI         = "false"
    TF_CONSUL_EC2_TAG    = "${data.terraform_remote_state.consul.consul_ec2_tag}"
    TF_VPC_CIDR          = "${data.terraform_remote_state.vpc.vpc_cidr}"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.vpn.id}"
  allocation_id = "${data.aws_eip.vpn.id}"
}

data "aws_eip" "vpn" {
  public_ip = "${var.eip}"
}

resource "aws_instance" "consulagent" {
  ami                    = "${data.aws_ami.consul.id}"
  instance_type          = "${var.agent_server_type}"
  key_name               = "${var.key_name}"
  subnet_id              = "${data.terraform_remote_state.vpc.private_subnets[0]}"
  vpc_security_group_ids = ["${list(data.terraform_remote_state.vpc.sg_ssh,aws_security_group.consul.id)}"]
  iam_instance_profile   = "${aws_iam_instance_profile.consul.name}"

  tags {
    Name = "Consul Agent"
  }
}

#data "template_file" "agent_consul_config" {
#  template = "${file("${path.module}/files/config_consul.tpl.sh")}"
#
#  vars {
#    TF_CONSUL_SERVERS = "${join(",",var.consul_servers)}"
#    TF_CONSUL_ROLE    = "client"
#    TF_CONSUL_OPTIONS = "-ui"
#    TF_CONSUL_PUBLIC = "yes"
#  }
#}


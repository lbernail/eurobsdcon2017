resource "aws_instance" "consulagent" {
  ami                    = "${data.aws_ami.consul.id}"
  instance_type          = "${var.agent_server_type}"
  key_name               = "${var.key_name}"
  subnet_id              = "${data.terraform_remote_state.vpc.private_subnets[0]}"
  vpc_security_group_ids = ["${list(data.terraform_remote_state.vpc.sg_ssh,aws_security_group.consul.id)}"]
  iam_instance_profile   = "${aws_iam_instance_profile.consul.name}"
  user_data              = "${data.template_file.consul_agent_config.rendered}"

  tags {
    Name = "Consul Agent"
  }
}

data "template_file" "consul_agent_config" {
  template = "${file("${path.module}/files/config_consul.tpl.sh")}"

  vars {
    TF_CONSUL_HOSTNAME   = "${var.cluster_id}_agent"
    TF_CONSUL_SERVERS    = "0"
    TF_CONSUL_SERVERROLE = "false"
    TF_CONSUL_BIND_IP    = "0.0.0.0"
    TF_CONSUL_UI         = "true"
    TF_CONSUL_EC2_TAG    = "${var.cluster_name}"
  }
}

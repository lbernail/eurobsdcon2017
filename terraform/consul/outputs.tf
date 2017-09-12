output "consul_server_ips" {
  value = ["${aws_instance.consul.*.private_ip}"]
}

output "consul_agent_ip" {
  value = ["${aws_instance.consulagent.private_ip}"]
}

output "sg_consul_client" {
  value = "${aws_security_group.consul_client.id}"
}

output "sg_consul_server" {
  value = "${aws_security_group.consul.id}"
}

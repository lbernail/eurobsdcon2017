output "vpn_server_ip" {
  value = ["${aws_instance.vpn.private_ip}"]
}

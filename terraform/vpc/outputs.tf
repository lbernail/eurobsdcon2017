output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "region" {
  value = "${var.region}"
}

output "azs" {
  value = "${var.azs[var.region]}"
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "public_subnets_cidr_block" {
  value = ["${aws_subnet.public.*.cidr_block}"]
}

output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "private_subnets_cidr_block" {
  value = ["${aws_subnet.private.*.cidr_block}"]
}

output "vpc_short_name" {
  value = "${var.vpc_short_name}"
}

output "vpc_name" {
  value = "${var.vpc_name}"
}

output "vpc_cidr" {
  value = "${var.cidr_block}"
}

output "sg_remote_access" {
  value = "${aws_security_group.remote_access.id}"
}

output "sg_admin" {
  value = "${aws_security_group.admin.id}"
}

output "sg_ssh" {
  value = "${aws_security_group.ssh.id}"
}

output "bastion_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

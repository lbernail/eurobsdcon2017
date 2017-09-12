data "aws_ami" "bastion" {
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

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.bastion.id}"
  instance_type          = "${var.bastion_instance_type}"
  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.public.*.id[0]}"
  vpc_security_group_ids = ["${list(aws_security_group.remote_access.id,aws_security_group.admin.id)}"]

  tags {
    Name = "${var.bastion_name}"
  }
}

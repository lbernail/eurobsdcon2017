resource "aws_iam_instance_profile" "consul" {
  name = "${var.cluster_id}_profile"
  roles = [ "${aws_iam_role.consul.name}" ]
  provisioner "local-exec" {
    command = "sleep 10" # wait for instance profile to be available
  }
}

resource "aws_iam_role" "consul" {
  name = "${var.cluster_id}_role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "consul" {
  name = "${var.cluster_id}_role_policy"
  role = "${aws_iam_role.consul.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [ 
                "ec2:DescribeInstances"
            ],
            "Effect": "Allow",
            "Resource": [ "*" ]
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

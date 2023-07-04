resource "aws_iam_role" "instance_role" {
	name = "instance-role"

	assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com",
          "ec2.amazonaws.com",
          "ecs.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
	tags = {
		Name = "InstanceRole"
	}
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile"
  role = "${aws_iam_role.instance_role.name}"
}


# Defining machine OS
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


resource "aws_instance" "instance" {
  ami           = "${data.aws_ami.amazon_linux_2.id}"
  instance_type = "t2.nano"
  key_name      = "instancekey"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  associate_public_ip_address = true
  tags = {
    Name = "Instance",
  }
}
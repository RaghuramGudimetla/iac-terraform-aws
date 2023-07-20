
/*
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_iam_instance_profile" "agent_profile" {
  name = "prefect-agent-profile"
  role = aws_iam_role.prefect_execution_role.name
}

resource "aws_instance" "prefect_agent" {

  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.nano"
  key_name      = "agent_key"

  iam_instance_profile = aws_iam_instance_profile.agent_profile.name

  associate_public_ip_address = true

  tags = {
    Name = "PrefectAgent"
  }

}
*/
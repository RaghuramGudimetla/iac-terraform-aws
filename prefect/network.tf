resource "aws_vpc" "prefect_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "prefect_subnet" {
  vpc_id     = aws_vpc.prefect_vpc.id
  cidr_block = "10.0.0.0/16"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "prefect_security_group" {
  name        = "prefect-security-group"
  description = "Prefect agent security group"
  vpc_id      = aws_vpc.prefect_vpc.id
}

resource "aws_security_group_rule" "https_outbound" {
  description       = "HTTPS outbound"
  type              = "egress"
  security_group_id = aws_security_group.prefect_security_group.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
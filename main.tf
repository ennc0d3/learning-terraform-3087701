data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security Group for the AWS services web"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "web-sg-rules-ingress-http" {
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "http"
  security_group_id = aws_security_group.web.id
  type              = "ingress"

}

resource "aws_security_group_rule" "web-sg-rules-ingress-https" {
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "https"
  security_group_id = aws_security_group.web.id
  type              = "ingress"

}

resource "aws_security_group_rule" "web-sg-rules-egress" {
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "-1"
  security_group_id = aws_security_group.web.id
  type              = "egress"

}
resource "aws_instance" "web" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone
  security_groups        = [aws_security_group.web.id]
  vpc_security_group_ids = [aws_security_group.web.id]


  tags = {
    Name = "learning-terraform"
  }
}

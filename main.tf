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

module "web-sg-group" {
  source        = "terraform-aws-modules/security-group/aws"
  egress_rules  = ["all-all"]
  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  name          = "web-sg-group"
  vpc_id        = data.aws_vpc.default.id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    "name" = "http-and-https"
  }
}
resource "aws_instance" "web" {
  name = "web-instance"
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone
  vpc_security_group_ids = [module.web-sg-group.security_group_id]


  tags = {
    Name = "learning-terraform"
  }
}

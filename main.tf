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

module "web_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "web-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "web_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "web-alb"
  vpc_id  = module.web_vpc.vpc_id
  subnets = module.web_vpc.public_subnets

  security_groups = [module.web-sg-group.security_group_id]

  listeners = {

    ex-http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix      = "h1"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      target_id        = aws_instance.web.id
    }
  }

  tags = {
    Environment = "Dev"
    Project     = "Example"
  }
}

module "web-sg-group" {
  source              = "terraform-aws-modules/security-group/aws"
  egress_rules        = ["all-all"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  name                = "web-sg-group"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_cidr_blocks  = ["0.0.0.0/0"]

  vpc_id = module.web_vpc.vpc_id
  tags = {
    Name        = "http-and-https"
    Environment = "dev"
  }
}
resource "aws_instance" "web" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  availability_zone      = module.web_vpc.azs[0]
  vpc_security_group_ids = [module.web-sg-group.security_group_id]
  subnet_id              = module.web_vpc.public_subnets[0]

  tags = {
    Name        = "learning-terraform"
    Environment = "dev"
  }
}

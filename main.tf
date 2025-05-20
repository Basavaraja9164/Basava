provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTPS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "blue_asg" {
  source = "./modules/asg"
  name   = "blue"
  ...
}

module "green_asg" {
  source = "./modules/asg"
  name   = "green"
  ...
}

resource "aws_route53_record" "blue" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = module.blue_asg.alb_dns
    zone_id                = module.blue_asg.alb_zone_id
    evaluate_target_health = true
  }

  set_identifier = "blue"
  weight         = 100
  ttl            = 60
  records        = []
}

resource "aws_route53_record" "green" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = module.green_asg.alb_dns
    zone_id                = module.green_asg.alb_zone_id
    evaluate_target_health = true
  }

  set_identifier = "green"
  weight         = 0
  ttl            = 60
  records        = []
}

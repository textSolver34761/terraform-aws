terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create a VPC
resource "aws_vpc" "vpcBpradon" {
  cidr_block = var.VPC_cidr
  tags       = { Name = "VPC_${var.name}" }
}

resource "aws_subnet" "publicBpradon" {
  vpc_id     = aws_vpc.vpcBpradon.id
  cidr_block = var.subnet_Public_cidr
  tags       = { Name = "subnet1_${var.name}" }
}

resource "aws_subnet" "privateBpradon" {
  vpc_id     = aws_vpc.vpcBpradon.id
  cidr_block = var.subnet_Private_cidr
  tags       = { Name = "subnet2_${var.name}" }
}

resource "aws_internet_gateway" "gwBpradon" {
  vpc_id = aws_vpc.vpcBpradon.id
  tags   = { Name = "internet_gateway_${var.name}" }
}

resource "aws_eip" "name" {}

resource "aws_nat_gateway" "privateGateway" {
  subnet_id     = aws_subnet.publicBpradon.id
  allocation_id = aws_eip.name.allocation_id
  tags          = { Name = "aws_nat_${var.name}" }
}

resource "aws_route" "default" {
  route_table_id         = aws_vpc.vpcBpradon.default_route_table_id
  destination_cidr_block = var.route_cidr
  gateway_id             = aws_internet_gateway.gwBpradon.id
}

resource "aws_route_table" "privrtBpradon" {
  vpc_id = aws_vpc.vpcBpradon.id
  route {
    cidr_block     = var.route_cidr
    nat_gateway_id = aws_nat_gateway.privateGateway.id
  }
}

resource "aws_route_table_association" "BenPradon-privrtb-assoc" {
  route_table_id = aws_route_table.privrtBpradon.id
  subnet_id      = aws_subnet.privateBpradon.id
}

resource "aws_security_group" "BenPradon-SG-ADM" {
  name        = "${var.name}-SG-ADM"
  description = "${var.name}-SG-ADM"
  vpc_id      = aws_vpc.vpcBpradon.id
  ingress {
    description      = "Allow SSH from external"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  egress {
    description = "Allow out traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = { Name = "security_group_${var.name}" }
}
resource "aws_security_group" "BenPradon-SG-RPROXY" {
  name        = "${var.name}-SG-RPROXY"
  description = "${var.name}-SG-RPROXY"
  vpc_id      = aws_vpc.vpcBpradon.id
  ingress {
    description     = "Allow SSH from admin"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.BenPradon-SG-ADM.id}"]
  }
  ingress {
    description      = "Allow HTTP from external"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
  egress {
    description      = "Allow out traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
}
resource "aws_security_group" "BenPradon-SG-WEB" {
  name        = "${var.name}-SG-WEB"
  description = "${var.name}-SG-WEB"
  vpc_id      = aws_vpc.vpcBpradon.id
  ingress {
    description     = "Allow SSH from admin"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.BenPradon-SG-ADM.id}"]
  }
  ingress {
    description     = "Allow HTTP from reverse proxy"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.BenPradon-SG-RPROXY.id}"]
  }
  egress {
    description      = "Allow out traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
  tags = { Name = "security_group_web_${var.name}" }
}
resource "aws_instance" "BenPradon-INSTANCE-ADM" {
  key_name                    = "test_keypair"
  ami                         = "ami-021d41cbdefc0c994"
  security_groups             = ["${aws_security_group.BenPradon-SG-ADM.id}"]
  subnet_id                   = aws_subnet.publicBpradon.id
  instance_type               = "t2.micro"
  associate_public_ip_address = var.false
  tags = {
    Name = "${var.name}-INSTANCE-ADM"
  }
}
resource "aws_instance" "BenPradon-INSTANCE-RPROXY" {
  key_name                    = "test_keypair"
  ami                         = "ami-021d41cbdefc0c994"
  security_groups             = ["${aws_security_group.BenPradon-SG-RPROXY.id}"]
  subnet_id                   = aws_subnet.publicBpradon.id
  instance_type               = "t2.micro"
  associate_public_ip_address = var.true
  tags = {
    Name = "${var.name}-INSTANCE-RPROXY"
  }
}
resource "aws_instance" "BenPradon-INSTANCE-WEB" {
  key_name                    = "test_keypair"
  ami                         = "ami-021d41cbdefc0c994"
  security_groups             = ["${aws_security_group.BenPradon-SG-WEB.id}"]
  subnet_id                   = aws_subnet.privateBpradon.id
  instance_type               = "t2.micro"
  associate_public_ip_address = var.false
  tags = {
    Name = "${var.name}-INSTANCE-WEB"
  }
}
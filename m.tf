/*provider "aws" {
  region = "eu-west-3"
}
resource "aws_vpc" "AROBINE-vpc" {
  cidr_block = "10.44.0.0/16"
  tags = {
    Name = "AROBINE-VPC"
  }
}
resource "aws_subnet" "AROBINE-pub" {
  vpc_id     = aws_vpc.AROBINE-vpc.id
  cidr_block = "10.44.1.0/24"
  tags = {
    Name = "AROBINE-pub"
  }
}
resource "aws_subnet" "AROBINE-priv" {
  vpc_id     = aws_vpc.AROBINE-vpc.id
  cidr_block = "10.44.2.0/24"
  tags = {
    Name = "AROBINE-priv"
  }
}
resource "aws_internet_gateway" "AROBINE-igw" {
  vpc_id = aws_vpc.AROBINE-vpc.id
  tags = {
    Name = "AROBINE-igw"
  }
}
resource "aws_eip" "AROBINE-nateip" {
}
resource "aws_nat_gateway" "AROBINE-natgw" {
  subnet_id     = aws_subnet.AROBINE-pub.id
  allocation_id = aws_eip.AROBINE-nateip.id
  tags = {
    Name = "AROBINE-natgw"
  }
}
resource "aws_route" "AROBINE-defroute" {
  route_table_id         = aws_vpc.AROBINE-vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.AROBINE-igw.id
}
resource "aws_route_table" "AROBINE-privrtb" {
  vpc_id = aws_vpc.AROBINE-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.AROBINE-natgw.id
  }
}
resource "aws_route_table_association" "AROBINE-privrtb-assoc" {
  route_table_id = aws_route_table.AROBINE-privrtb.id
  subnet_id      = aws_subnet.AROBINE-priv.id
}
resource "aws_security_group" "AROBINE-SG-ADM" {
  name        = "AROBINE-SG-ADM"
  description = "AROBINE-SG-ADM"
  vpc_id      = aws_vpc.AROBINE-vpc.id
  ingress {
    description      = "Allow SSH from external"
    from_port        = 22
    to_port          = 22
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
resource "aws_security_group" "AROBINE-SG-RPROXY" {
  name        = "AROBINE-SG-RPROXY"
  description = "AROBINE-SG-RPROXY"
  vpc_id      = aws_vpc.AROBINE-vpc.id
  ingress {
    description     = "Allow SSH from admin"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.AROBINE-SG-ADM.id}"]
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
resource "aws_security_group" "AROBINE-SG-WEB" {
  name        = "AROBINE-SG-WEB"
  description = "AROBINE-SG-WEB"
  vpc_id      = aws_vpc.AROBINE-vpc.id
  ingress {
    description     = "Allow SSH from admin"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.AROBINE-SG-ADM.id}"]
  }
  ingress {
    description     = "Allow HTTP from reverse proxy"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.AROBINE-SG-RPROXY.id}"]
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
resource "aws_instance" "AROBINE-INSTANCE-ADM" {
  key_name                    = "test_keypair"
  ami                         = "ami-021d41cbdefc0c994"
  security_groups             = ["${aws_security_group.AROBINE-SG-ADM.id}"]
  subnet_id                   = aws_subnet.AROBINE-pub.id
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  tags = {
    Name = "AROBINE-INSTANCE-ADM"
  }
}
resource "aws_instance" "AROBINE-INSTANCE-RPROXY" {
  key_name                    = "test_keypair"
  ami                         = "ami-021d41cbdefc0c994"
  security_groups             = ["${aws_security_group.AROBINE-SG-RPROXY.id}"]
  subnet_id                   = aws_subnet.AROBINE-pub.id
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  tags = {
    Name = "AROBINE-INSTANCE-RPROXY"
  }
}
resource "aws_instance" "AROBINE-INSTANCE-WEB" {
  key_name                    = "test_keypair"
  ami                         = "ami-021d41cbdefc0c994"
  security_groups             = ["${aws_security_group.AROBINE-SG-WEB.id}"]
  subnet_id                   = aws_subnet.AROBINE-priv.id
  instance_type               = "t2.micro"
  associate_public_ip_address = "false"
  tags = {
    Name = "AROBINE-INSTANCE-WEB"
  }
}*/
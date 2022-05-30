variable "true" {
  type    = bool
  default = true
}

variable "false" {
  type    = bool
  default = false
}

variable "access_key" {
  type    = string
  default = "AKIA6AIDAZZFZDOOZUEA"
}

variable "secret_key" {
  type    = string
  default = "s21OLc+qv9Ug3Kr5CGodsCFO9/JP2PB38voYrbh3"
}

variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "name" {
  type    = string
  default = "BenPradon"
}

variable "VPC_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_Public_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_Private_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "route_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ingress_sg_adm" {
  type = any
  default = {
    description      = "Allow SSH from external"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
}

/*
variable "egress_sg_adm" {
  default = {
    description = "Allow out traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}*/

variable "ingress_http" {
  type = any
  default = {
    description      = "Allow HTTP from external"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
}

variable "egress_proxy" {
  type = any
  default = {
    description      = "Allow out traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
}

variable "ingress_proxy_t" {
  default = {
    "my ingress rule" = {
      description      = "Allow SSH from admin"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
    },
    "my other ingress rule" = {
      description      = "Allow HTTP from external"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
    }
  }
  type = map(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    security_groups  = list(string)
  }))
}
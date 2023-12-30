terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

variable "access_key" {
  type = string
}

variable "secret_token" {
  type = string
}

provider "aws" {
  region     = "eu-west-3"
  access_key = var.access_key
  secret_key = var.secret_token
}

variable "cidr_block" {

}

variable "public_key_path" {

}

resource "aws_vpc" "first-trial" {
  cidr_block = var.cidr_block
  tags = {
    "Name"  = "dev-vpc",
    "mytag" = "Hello"
  }
}

resource "aws_subnet" "subnet-trial" {
  vpc_id            = aws_vpc.first-trial.id
  cidr_block        = "10.2.10.0/24"
  availability_zone = "eu-west-3a"
  tags = {
    "Name" = "dev-subnet"
  }
}

resource "aws_route_table" "route-table-trial" {
  vpc_id = aws_vpc.first-trial.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway-trial.id
  }

  tags = {
    Name = "dev-route-table"
  }
}

resource "aws_internet_gateway" "internet-gateway-trial" {
  vpc_id = aws_vpc.first-trial.id

  tags = {
    Name = "dev-internet-gateway"
  }
}

resource "aws_route_table_association" "route-table-association-trial" {
  subnet_id      = aws_subnet.subnet-trial.id
  route_table_id = aws_route_table.route-table-trial.id
}

resource "aws_security_group" "security-group-trial" {
  name        = "dev-security-group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.first-trial.id

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nginx Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security-group-sg"
  }
}

data "aws_ami" "latest-amazon-linus" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "instance-trial" {
  ami           = data.aws_ami.latest-amazon-linus.id
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.subnet-trial.id
  vpc_security_group_ids = [aws_security_group.security-group-trial.id]
  availability_zone      = "eu-west-3a"

  associate_public_ip_address = true
  key_name                    = aws_key_pair.key-pair-trial.key_name

  tags = {
    Name = "dev-instance"
  }
}

resource "aws_key_pair" "key-pair-trial" {
  key_name   = "new-key"
  public_key = file(var.public_key_path) # Generate a private key according to the provided public key
}

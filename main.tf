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

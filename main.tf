terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-3"
  access_key = var.access_key
  secret_key = var.secret_token
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "first-trial"
  cidr = var.cidr_block

  azs             = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
  private_subnets = ["10.2.1.0/24"]
  public_subnets  = ["10.2.101.0/24"]

  tags = {
    Name = "first-trial"
  }
}

module "webservers" {
  source = "./modules/webservers"

  vpc_id          = module.vpc.vpc_id
  public_key_path = var.public_key_path
  subnet_id       = module.vpc.public_subnets[0]
}

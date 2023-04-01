terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "net" {
  source = "./modules/net"
  vpc_name = {
    dev  = "dev"
    hom  = "hom"
    prod = "prod"
  }
  cidr_block           = "10.11.0.0/16"
  enable_dns_hostnames = true
  sub_public_count     = 3
  sub_private_count    = 3
  gateway_name = {
    dev  = "dev"
    hom  = "hom"
    prod = "prod"
  }
  subnet_name = {
    dev  = "dev"
    hom  = "hom"
    prod = "prod"
  }
}

module "sg" {
  source = "./modules/sg"

  sg_name_server = {
    dev  = "dev"
    hom  = "hom"
    prod = "prod"
  }
  sg_name_web = {
    dev  = "dev"
    hom  = "hom"
    prod = "prod"
  }
  vpc = module.net.vpc_id
}

module "vms" {
  source = "./modules/vms"

  name_web = {
    dev  = "dev"
    hom  = "hom"
    prod = "prod"
  }
  counter  = 5
  instance = "t2.micro"

  ami_ubuntu             = "ami-007855ac798b5175e"
  aws_public_subnet      = module.net.subnet_public
  aws_web_security_group = [module.sg.sg_web_id]
  volume_size_web        = 20
  volume_type_web        = "gp3"

  ami_amazon_linux          = "ami-00c39f71452c08778"
  aws_private_subnet        = module.net.subnet_private
  aws_server_security_group = [module.sg.sg_server_id]
  volume_size_server        = terraform.workspace == "dev" ? 10 : (terraform.workspace == "hom" ? 20 : 50)
  volume_type_server        = "gp3"
}

module "db" {
  source = "./modules/db"

  db_name = {
    dev  = "dev"
    hom  = "hom"
    prod = "prod"
  }
  aws_web_security_group = [module.sg.sg_server_id]
}
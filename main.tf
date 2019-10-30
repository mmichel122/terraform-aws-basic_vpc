provider "aws" {
  region  = "eu-west-2"
  profile = "logging"
}

terraform {
  backend "remote" {
    organization = "modus-demo"

    workspaces {
      name = "aws-vpc-dev-eu-west"
    }
  }
}

# Variables
variable "env_name" {
}

variable "vpc_cidr" {
}

variable "az" {
}

variable "service_ports" {
  type = "list"
}

module "network" {
  source   = "./modules/network"
  env_name = var.env_name
  vpc_cidr = var.vpc_cidr
  az       = var.az
}

module "compute" {
  source         = "./modules/compute"
  public_subnets = module.network.public_subnets
  env_name       = var.env_name
  vpc_cidr       = var.vpc_cidr
  vpc_id         = module.network.vpc
  az             = var.az
  service_ports  = var.service_ports
}

output "vpc_id" {
  value = module.network.vpc
}
output "subnets_id" {
  value = module.network.public_subnets
}

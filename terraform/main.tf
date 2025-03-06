terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # We'll configure a backend for state storage later
  # This will be stored locally for now
  backend "local" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SecondBrain"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Import modules for different components of our infrastructure
module "networking" {
  source = "./modules/networking"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "database" {
  source = "./modules/database"

  environment   = var.environment
  vpc_id        = module.networking.vpc_id
  subnet_ids    = module.networking.private_subnet_ids
  db_name       = var.db_name
  db_username   = var.db_username
  db_password   = var.db_password
  db_port       = var.db_port
  instance_type = var.environment == "production" ? "db.t4g.small" : "db.t4g.micro"
}

module "api" {
  source = "./modules/api"

  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.private_subnet_ids
  public_subnet_ids = module.networking.public_subnet_ids
  db_endpoint       = module.database.db_endpoint
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  instance_type     = var.environment == "production" ? "t4g.small" : "t4g.micro"
} 
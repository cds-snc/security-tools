# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.39.0"
    }
  }
}

provider "aws" {
  region = var.region
}

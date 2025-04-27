provider "aws" {
  region  = var.region
  profile = "iam-dev"
  default_tags {
    tags = var.tags
  }
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

#   backend "s3" {
#     bucket = "exeter-terraform-dev"
#     key     = "Dev/DevOps/Cloud/Agents/Infra/AzureDevops/VPC/terraform.tfstate"
#     region  = "us-east-1"
#     encrypt = true
#   }
}
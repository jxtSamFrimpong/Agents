provider "aws" {
  region  = var.region
  profile = "iam-dev"
  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
  profile = "iam-dev"
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }

    # backend "s3" {
    #   bucket = "exeter-terraform-dev"
    #   key     = "Dev/DevOps/Cloud/Agents/Infra/AzureDevops/EKS/terraform.tfstate"
    #   region  = "us-east-1"
    #   # encrypt = true
    # }
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "--profile", "iam-dev", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "--profile", "iam-dev", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}
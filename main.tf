terraform {
  required_version = ">= 1.3.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "s3-tf-backend-mydemo"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}

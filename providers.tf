terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.72.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Backend Remoto Seguro y Económico (100% S3 nativo con bloqueo de estado condicional)
  backend "s3" {
    bucket       = "tfstate-997053009916-eu-west-1"
    key          = "root/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true # Cifrado SSE-S3 gratuito
    use_lockfile = true # Bloqueo nativo en S3 (sin costes de base de datos)
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "default"
}

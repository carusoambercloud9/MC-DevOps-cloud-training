terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "mc_prod_bucket" {
  bucket = "mc-cicd-prod-amber-2026"
  tags = {
    Name        = "mc-cicd-prod"
    Environment = "prod"
    Project     = "MaidCentral"
  }

  lifecycle {
    ignore_changes = all
  }
}
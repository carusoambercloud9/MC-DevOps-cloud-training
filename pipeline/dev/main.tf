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

resource "aws_s3_bucket" "mc_dev_bucket" {
  bucket = "mc-cicd-dev-amber-2026"
  tags = {
    Name        = "mc-cicd-dev"
    Environment = "dev"
    Project     = "MaidCentral"
  }

lifecycle {
    ignore_changes = all
  }
}
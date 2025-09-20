terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource aws_s3_bucket "tfbackend" {
  bucket = "tfstoragebucketdemo2025"
  tags = {
    Name        = "tfbackend"
    Environment = "Dev"
  }
}



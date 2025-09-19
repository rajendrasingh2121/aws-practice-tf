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
# Create a VPC
resource "aws_vpc" "firstvpc" {
  cidr_block = "10.0.0.0/28"
  tags = {
    Name = "firstvpc"
  }

}

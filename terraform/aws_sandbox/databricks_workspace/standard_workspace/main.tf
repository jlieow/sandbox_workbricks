terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

	backend "s3" {
    bucket = "jlieow-tfstate-54321abcde"
    key    = "aws_sandbox/databricks_workspace/standard_workspace/terraform.tfstate"
    region = "eu-west-2"
  }
}

# Configure the AWS Provider
provider "aws" {
	profile = "aws-sandbox-field-eng"
  region = "eu-west-2"
}


# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

	tags = {
    Name = "jlieow"
  }
}
###############################################################################
# TFC Business Unit — Provider
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  # backend "s3" {
  #   bucket         = "<tfc-tf-state-bucket>"
  #   key            = "connect/instances/tfc-<env>-<region>/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote state — required in enterprise.
  # Fill in the bucket and DynamoDB table provided by your platform team.
  # ---------------------------------------------------------------------------
  backend "s3" {
    bucket         = "<platform-tf-state-bucket>"
    key            = "connect/dynamodb/ls-uw2/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "<platform-tf-state-lock-table>"
  }
}

provider "aws" {
  region = var.aws_region
  # Credentials come from your SSO session — run `aws sso login` before apply.
}

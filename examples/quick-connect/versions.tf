terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0.0" }
  }

  # ---------------------------------------------------------------------------
  # Remote state — uncomment and fill in your platform's S3 backend details
  # ---------------------------------------------------------------------------
  # backend "s3" {
  #   bucket         = "<platform-tf-state-bucket>"
  #   key            = "connect/quick-connect/tfc-retail-tccivr-prod-ue1/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "<platform-tf-state-lock-table>"
  # }
}

provider "aws" {
  region = var.aws_region
}

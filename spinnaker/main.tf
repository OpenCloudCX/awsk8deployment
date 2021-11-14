# Complete example

terraform {
  required_version = "~> 1.0.8"
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  # version             = ">= 3.0"
}

provider "aws" {
  alias               = "prod"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  # version             = ">= 3.0"
}


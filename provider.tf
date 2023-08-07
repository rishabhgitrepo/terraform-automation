terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.1.0"
    }
  }
  backend "s3" {
    bucket         = "rishiterraformstatestore"
    key            = "terraform-state-file-june23-rish"
    region         = "ap-south-1"
    role_arn       = "arn:aws:iam::232247148826:role/stsassume-role"
    dynamodb_table = "terraformstatetable"
  }
}

provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn     = "arn:aws:iam::232247148826:role/stsassume-role"
    session_name = "terraform-sts"
  }
}



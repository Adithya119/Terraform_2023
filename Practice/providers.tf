terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

provider "null" {
  
}

# backend for state files using s3 bucket and dynamodb table
terraform {
  backend "s3" {
    bucket = "adi-tfstate-bucket-1"
    key = "statefiles.tfstate"
    region = "ap-south-1"
    dynamodb_table = "for_tf_locking"
  }
}
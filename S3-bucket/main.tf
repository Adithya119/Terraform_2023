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

resource "aws_s3_bucket" "my1stbucket" {
  bucket = "na-imatai-ni-noqu"
  acl    = "public-read"
}
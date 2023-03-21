resource "aws_vpc" "primary-vpc" {
  cidr_block       = "192.168.0.0/16"
  
  tags = {
    Name = "primary-1"
  }
}

resource "aws_subnet" "web-1" {
  vpc_id     = aws_vpc.primary-vpc.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "web1"
  }
}

resource "aws_subnet" "web-2" {
  vpc_id     = aws_vpc.primary-vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "web2"
  }
}

resource "aws_subnet" "db-1" {
  vpc_id     = aws_vpc.primary-vpc.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "db1"
  }
}

resource "aws_subnet" "db-2" {
  vpc_id     = aws_vpc.primary-vpc.id
  cidr_block = "192.168.3.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "db2"
  }
}
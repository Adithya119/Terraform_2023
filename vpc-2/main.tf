resource "aws_vpc" "primary-vpc" {
  cidr_block       = var.subnet_vpc
  
  tags = {
    Name = "primary-1"
  }
}

resource "aws_subnet" "web-1" {
  vpc_id     = aws_vpc.primary-vpc.id
  cidr_block = var.subnet_cidrs[0]
  availability_zone = var.subnet_zones[0]

  tags = {
    Name = var.subnet_names[0]
  }
}

resource "aws_subnet" "web-2" {
  vpc_id     = aws_vpc.primary-vpc.id
  cidr_block = var.subnet_cidrs[1]
  availability_zone = var.subnet_zones[1]

  tags = {
    Name = var.subnet_names[1]
  }
}

resource "aws_subnet" "db-1" {
  vpc_id     = aws_vpc.primary-vpc.id
  cidr_block = var.subnet_cidrs[2]
  availability_zone = var.subnet_zones[2]

  tags = {
    Name = var.subnet_names[2]
  }
}

resource "aws_subnet" "db-2" {
  vpc_id     = aws_vpc.primary-vpc.id
  cidr_block = var.subnet_cidrs[3]
  availability_zone = var.subnet_zones[3]

  tags = {
    Name = var.subnet_names[3]
  }
}
# infra creation: 
  # vpc, subnets
  # network: igw, route table & association
  # SG, ec2
  # subnet group, db-vm
# ---

# ***   Note: All resources except route_table_association have to reference vpc_id  ***

resource "aws_vpc" "primary-vpc" {
  cidr_block = var.vpc_cidr
  
  tags = {
    Name = "primary-1"
  }
}


resource "aws_subnet" "subnets" {
  count = length(var.subnet_cidrs)              # this is for loop => for count = 4;  # this is "length()". not "len()"
  vpc_id     = aws_vpc.primary-vpc.id   
  cidr_block = var.subnet_cidrs[count.index]
  availability_zone = var.subnet_zones[count.index]

  tags = {
    Name = var.subnet_names[count.index]
  }
}

# From here, I have added SG creation code
resource "aws_security_group" "Web-SG" {   
  vpc_id      = aws_vpc.primary-vpc.id                    # associate SG to your cloud (vpc)
  name        = "Web-SG"
  description = "Allow SSH, HTTP & HTTPS inbound traffic"
  
ingress {                                                 # you can include multiple ingress blocks
    description      = "Allow SSH from anywhere"
    from_port        = local.ssh_port
    to_port          = local.ssh_port
    protocol         = local.tcp
    cidr_blocks      = [local.anywhere]                   # brackets required because it's plural
}

ingress {
    description      = "Allow HTTP from anywhere"
    from_port        = local.http_port
    to_port          = local.http_port
    protocol         = local.tcp
    cidr_blocks      = [local.anywhere]
}

ingress {
    description      = "ALlow HTTPS from anywhere"
    from_port        = local.https_port
    to_port          = local.https_port
    protocol         = local.tcp
    cidr_blocks      = [local.anywhere]
}

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [local.anywhere]
    ipv6_cidr_blocks = ["::/0"]
  }
  
tags = {
    Name = "Web-SG"       # SG name for Web servers. That's why we have HTTP(S) ports open.
  }
}

# Postgres SG
resource "aws_security_group" "DB-SG" {   
  vpc_id      = aws_vpc.primary-vpc.id    
  name        = "DB-SG"
  description = "Allow connections only from ec2 instances in our vpc"
  
ingress {
    description      = "Allow connections only from ec2 instances in our vpc"
    from_port        = local.pg_port
    to_port          = local.pg_port
    protocol         = local.tcp
    cidr_blocks      = [var.vpc_cidr]    # open Postgres only to ec2 instances in our vpc
}

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "DB-SG"
  }
}

# igw
resource "aws_internet_gateway" "igw-1" {     
  vpc_id = aws_vpc.primary-vpc.id          # igw-1 is attached to this vpc
  tags = {
    Name = "igw-1"
  }
}

# A route table connects specified traffic to igw, which is attached to some vpc
# public route table
resource "aws_route_table" "public_route_table" {       
  vpc_id = aws_vpc.primary-vpc.id
  
  route {                                         # route block
  cidr_block = local.anywhere                        # allow traffic from specified cidrs (from)
  gateway_id = aws_internet_gateway.igw-1.id         # send the allowed traffic to specified igw (to)
  }

  tags = {
    Name = "public"
  }
}


# You actually dont need to create a private route table at all because the default route table is enough to route -
# connections within the vpc.
resource "aws_route_table" "private_route_table" {    # incoming connections from outside vpc are disbaled by not giving a "route" block, unlike in public route table.
  vpc_id = aws_vpc.primary-vpc.id
                                                    
  tags = {
    Name = "private"
  }
}

# A route table association connects a route table to specific subnet inside a vpc
resource "aws_route_table_association" "web-1_public_association" {
  subnet_id = aws_subnet.subnets[0].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "web-2_public_association" {
  subnet_id = aws_subnet.subnets[1].id
  route_table_id = aws_route_table.public_route_table.id
}

# private route association is obviously not required because db subnets don't need any incoming connections from outside - 
# the vpc 
resource "aws_route_table_association" "db-1_private_association" {
  subnet_id = aws_subnet.subnets[4].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "db-2_private_association" {
  subnet_id = aws_subnet.subnets[5].id
  route_table_id = aws_route_table.private_route_table.id
}
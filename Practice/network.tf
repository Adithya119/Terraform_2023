# infra creation: 
  # vpc, subnets
  # network: igw, route table & association
  # SG, ec2
  # subnet group, db-vm
# ---

# ***   Note: All resources except route_table_association have to reference vpc_id  ***


resource "aws_vpc" "vpc-2" {
    cidr_block = var.vpc_cidr
    
    tags = {
        Name = format("%s-spc-vpc", terraform.workspace)    # giving this in locals.tf is better.
        Env = terraform.workspace
    }
}

resource "aws_subnet" "web-subnets" {
    count = length(var.web-subnet-cidrs)        # this is "length()". not "len()"
    vpc_id = aws_vpc.vpc-2.id
    cidr_block = var.web-subnet-cidrs[count.index]
    availability_zone = var.web-az[count.index]
    tags = {
        Name = format("%s-web-subnet-%d", terraform.workspace, count.index)
        Env = terraform.workspace
    }
}

resource "aws_subnet" "db-subnets" {
    count = length(var.db-subnet-cidrs)        
    vpc_id = aws_vpc.vpc-2.id
    cidr_block = var.db-subnet-cidrs[count.index]
    availability_zone = var.db-az[count.index]
    tags = {
        Name = format("%s-db-subnet-%d", terraform.workspace, count.index)
        Env = terraform.workspace
    }
}

resource "aws_security_group" "ssh-sg" {
    vpc_id = aws_vpc.vpc-2.id     # associate SG to your cloud (vpc)
    name = "ssh"
    description = "allow ssh inbound"
    
    ingress {                   # you can include multiple ingress blocks
        to_port = local.ssh-port
        from_port = local.ssh-port
        protocol = local.protocol
        cidr_blocks = [local.anywhere]     # brackets required because it's plural
    }

    egress {
        protocol = "-1"
        to_port = 0
        from_port = 0
        cidr_blocks = [local.anywhere]
    }
    
    tags = {
        Name = "ssh-sg"
        Env = terraform.workspace
    }
}

resource "aws_security_group" "http-sg" {
    vpc_id = aws_vpc.vpc-2.id
    name = "http"
    description = "allow http inbound"
    
    ingress {
        to_port = local.http-port
        from_port = local.http-port
        protocol = local.protocol
        cidr_blocks = [local.anywhere]
    }

    egress {
        protocol = "-1"
        to_port = 0
        from_port = 0
        cidr_blocks = [local.anywhere]
    }

    tags = {
        Name = "http-sg"
        Env = terraform.workspace
    }
}

resource "aws_security_group" "ssh-db-sg" {
    vpc_id = aws_vpc.vpc-2.id
    name = "ssh for db"
    description = "allow ssh for db inbound within vpc"

    ingress {
        to_port = local.ssh-port
        from_port = local.ssh-port
        protocol = local.protocol
        cidr_blocks = [var.vpc_cidr]
    }

    egress {
        protocol = "-1"
        to_port = 0
        from_port = 0
        cidr_blocks = [local.anywhere]
    }

    tags = {
        Name = "ssh-db-sg"
        Env = terraform.workspace
    }
}


resource "aws_internet_gateway" "igw-2" {
    vpc_id = aws_vpc.vpc-2.id
    tags = {
        Name = "igw-2"
    }
}

resource "aws_route_table" "public_route_table_2" {
    vpc_id = aws_vpc.vpc-2.id
    
    route {
        gateway_id = aws_internet_gateway.igw-2.id
        cidr_block = local.anywhere
    }

    tags = {
        Name = "public_rt"
    }
}

# You dont need to create a private route table at all because the default route table is enough to route connections -
# within the vpc.

resource "aws_route_table_association" "public_association_2" {
    route_table_id = aws_route_table.public_route_table_2.id
    subnet_id = aws_subnet.web-subnets[0].id
}

resource "aws_route_table_association" "public_association_3" {
    route_table_id = aws_route_table.public_route_table_2.id
    subnet_id = aws_subnet.web-subnets[1].id
}

# private route association is obviously not required because db subnets don't need any incoming connections from outside - 
# the vpc 
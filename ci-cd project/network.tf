#  infra creation for self-developed ci/cd project


resource "aws_vpc" "vpc-cicd-1" {
    cidr_block = var.vpc-cidr
    tags = {
        name = "vpc-cicd-1"
    }
}


resource "aws_subnet" "subnets-cicd" {
    count = length(var.subnet-cidrs)
    vpc_id = aws_vpc.vpc-cicd-1.id
    cidr_block = var.subnet-cidrs[count.index]
    availabilty_zone = var.AZs[count.index]
    tags = {
        name = var.subnet-names[count.index]
    }
}


resource "aws_security_group" "SG-1" {
    vpc_id = aws_vpc.vpc-cicd-1.id

    ingress {           # expose port 22 for all incoming connections
        from_port = 22     # no quotes for numbers
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]   # blocks --> plural     
        protocol = "TCP"
    }

    ingress {
        from_port = 80   # http
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "TCP"
    }

    ingress {
        from_port = 443  # https
        to_port = 443
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "TCP"
    }

    egress {       # allow all traffic to go outside
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        name = "web-SG"
        description = "allow ssh, http(s) on ports 22, 80 & 443"
    }
}


resource "aws_internet_gateway" "igw-for-cicd" {
    vpc_id = aws_vpc.vpc-cicd-1.id
    tags = {
        name = "igw-for-cicd"
    }
}


resource "aws_route_table" "public_rt_cicd" {   # define a route table here
    vpc_id = aws_vpc.vpc-cicd-1.id
    route {             # mention only the incomming connections in this route block
        gateway_id = aws_internet_gateway.igw-for-cicd.id
        cidr_block = "0.0.0.0/0"  
    }
    tags = {
        name = "public_route_table_cicd"
    }
}


resource "aws_route_table_association" "public-route-table-association" {           # give both incoming & outgoing connections here
    route_table_id = aws_route_table.public_rt_cicd.id            # incoming connections come from here
    subnet_id = aws_subnet.subnets-cicd[0]                        # incoming traffic will be directed here
}

resource "aws_route_table_association" "public-route-table-association" {   
    route_table_id = aws_route_table.public_rt_cicd.id 
    subnet_id = aws_subnet.subnets-cicd[1]
}
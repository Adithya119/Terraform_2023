resource "aws_vpc" "primary-vpc-2" {
    cidr_block = var.vpc_cidr

    tags = {                    # tags is an arguement by itself. Hence, definitely use "=" after tags.
        Name = "spc-vpc"
    }
}


resource "aws_subnet" "web-subnets" {              
    count = length(var.web_subnet_cidrs)
    vpc_id = aws_vpc.primary-vpc-2.id
    cidr_block = var.web_subnet_cidrs[count.index]
    availability_zone = var.web_subnet_zones[count.index]     # AZ's

    tags = {
        Name = var.web_subnet_names[count.index]
    }
}


resource "aws_subnet" "db-subnets" {              # defining db-subnets separately to be able to create db-vms only in db subnets.
    count = length(var.db_subnet_cidrs)
    vpc_id = aws_vpc.primary-vpc-2.id
    cidr_block = var.db_subnet_cidrs[count.index]
    availability_zone = var.db_subnet_zones[count.index]    

    tags = {
        Name = var.db_subnet_names[count.index]
    }
}


resource "aws_security_group" "Web-SG" {
    vpc_id = aws_vpc.primary-vpc-2.id
    name = "Web-SG"
    description = "Allow ssh, http & https traffic"
    
    ingress {
        description = "Allow traffic on port 8080"
        from_port = local.spc_port
        to_port = local.spc_port
        protocol = local.tcp
        cidr_blocks = [local.anywhere]                  # plural arguements require a list of string
    }
    
    ingress {
        description = "Allow all ssh traffic"            # type = ssh   is not required
        from_port = local.ssh_port                                  # from & to port
        to_port = local.ssh_port
        protocol = local.tcp
        cidr_blocks = [local.anywhere]
    }

    ingress {
        description = "Allow http traffic"             # required to browse the web UI of app inside avm
        from_port = local.http_port                                  
        to_port = local.http_port
        protocol = local.tcp
        cidr_blocks = [local.anywhere]
    }

    ingress {
        description = "Allow https traffic"            
        from_port = local.https_port                                  
        to_port = local.https_port
        protocol = local.tcp
        cidr_blocks = [local.anywhere]
    }

    egress {
        description = "Allow all outgoing traffic"            
        from_port = 0                                  
        to_port = 0
        protocol = "-1"               # If you select a protocol of -1 (semantically equivalent to all), you must specify a from_port and to_port equal to 0.
        cidr_blocks = [local.anywhere]
    }

    tags = {
        Name = "Web-SG"
    }
}


resource "aws_security_group" "DB-SG" {
    vpc_id = aws_vpc.primary-vpc-2.id
    name = "DB-SG"
    description = "Allow traffic only from within the vpc"

    ingress {
        description = "Allow all ssh traffic from within the vpc"            
        from_port = local.ssh_port                                
        to_port = local.ssh_port
        protocol = local.tcp
        cidr_blocks = [var.vpc_cidr]
    }

    ingress {
        description = "Allow all traffic from within the vpc - for ping test"            
        from_port = 0                               
        to_port = 0
        protocol = -1
        cidr_blocks = [var.vpc_cidr]
    }

    ingress {
        description = "for DB instances"
        from_port = local.Postgres_port
        to_port = local.Postgres_port
        protocol = local.tcp
        cidr_blocks = [var.vpc_cidr]           # Allow traffic only from within the vpc
    }

    egress {
        description = "Allow all outgoing traffic"            
        from_port = 0                                  
        to_port = 0
        protocol = "-1"          
        cidr_blocks = [local.anywhere]
    }

    tags = {
        Name = "DB-SG"
    }
}


resource "aws_internet_gateway" "igw-2" {
    vpc_id = aws_vpc.primary-vpc-2.id          # don't forget to give .id  at the end
    tags = {
        Name = "igw-2"
    }
}


resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.primary-vpc-2.id

    route {                                           # a list of route objects
        gateway_id = aws_internet_gateway.igw-2.id
        cidr_block = local.anywhere                      # will allow all connections from igw-1 to this table.  ## this arguement is singular => hence doesn't require a string.
    }

    tags = {
        Name = "public"
    }
}





resource "aws_route_table_association" "web-1-subnet-association" {
    subnet_id = aws_subnet.web-subnets[0].id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "web-2-subnet-association" {
    subnet_id = aws_subnet.web-subnets[1].id
    route_table_id = aws_route_table.public_route_table.id
}


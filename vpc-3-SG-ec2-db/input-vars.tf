variable "vpc_cidr" {
    default = "192.168.0.0/16"
    description = "This is the VPC cidr"
    type = string
}

variable "subnet_cidrs" {
    default = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24"]
    description = "These are subnet cidr ranges"
}

variable "subnet_zones" {
    default = ["ap-south-1a", "ap-south-1b", "ap-south-1c", "ap-south-1a", "ap-south-1b", "ap-south-1c"]
    description = "Availability Zones for the subnets"
}

variable "subnet_names" {
    default = ["WEB-1", "WEB-2", "APP-1", "APP-2", "DB-1", "DB-2"]  # there are 2 web subnets - for HA
    description = "Names of subnets"
}

# keys can be saved in locals file as well
variable "key2-pub" {
    default = "key2.pub"
}

variable "key2-private" {
    default = "key2.pem"
}

variable "username" {
    default = "ubuntu"
}

# trigger
variable "build_id" {
    default = 2
}
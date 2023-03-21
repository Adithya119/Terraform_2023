variable "subnet_vpc" {
    default = "192.168.0.0/16"
    description = "This is the VPC cidr"
    type = string
}

variable "subnet_cidrs" {
    default = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
    description = "These are subnet cidr ranges"
}

variable "subnet_zones" {
    default = ["ap-south-1a", "ap-south-1b", "ap-south-1a", "ap-south-1b"]
    description = "Availability Zones for the subnets"
}

variable "subnet_names" {
    default = ["WEB-1", "WEB-2", "APP-1", "APP-2"]
    description = "Names of subnets"
}
  
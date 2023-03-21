variable "vpc_cidr" {
    default = "192.167.0.0/16"
}

#variable "vpc_name" {
 #   default = "practice-vpc"
#}

variable "instance-type" {
    default = "t2.medium"
}

# separating web & db subnets
variable "web-subnet-cidrs" {
    default = ["192.167.1.0/24", "192.167.2.0/24"]
}

variable "db-subnet-cidrs" {
    default = ["192.167.3.0/24", "192.167.4.0/24"]
}

variable "web-az" {
    default = ["ap-south-1a", "ap-south-1b"]
}

variable "db-az" {
    default = ["ap-south-1a", "ap-south-1b"]
}

#variable "web-subnet-names" {
#    default = ["web-1", "web-2"]
#}

#variable "db-subnet-names" {
 #   default = ["db-1", "db-2"]
#}


variable "pub-key" {
    default = "key2.pub"
}

variable "private-key" {
    default = "key2.pem"
}

variable "build_id" {
    default = 1
}

variable "user" {
    default = "ubuntu"
}

#variable "web-vm-names" {
 #   default = ["web-vm-1", "web-vm-2"]
#}
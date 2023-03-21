variable "vpc-cidr" {
    default = "172.32.0.0/16"
}

variable "subnet-cidrs" {
    default = ["172.32.0.0/24", "172.32.1.0/24", "172.32.2.0/24", "172.32.3.0/24"]
}

variable "AZs" {
    default = ["ap-south-1a", "ap-south-1b", "ap-south-1c", "ap-south-1a"]
}

variable "subnet-names" {
    default = ["web-1", "web-2", "web-3", "web-4"]
}

variable "vm-names" {
    default = ["vm-1", "vm-2"]
}
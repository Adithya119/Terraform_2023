output "vpc_name" {
    value = aws_vpc.vpc-cicd-1.tags
}

output "SG-name" {
    value = aws_security_group.SG-1.tags
}

output "igw-name" {
    value = aws_internet_gateway.igw-for-cicd.tags
}

output "public-rt-name" {
    value = aws_route_table.public_rt_cicd.tags
}

output "vm-1-public-ip" {
    value = aws_instance.web-vms[0].public_ip
}

output "vm-1-tags" {
    value = aws_instance.web-vms[0].tags
}
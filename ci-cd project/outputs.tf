output "vpc_name" {
    value = aws_vpc.vpc-cicd-1.tags_all
}

output "SG-name" {
    value = aws_security_group.SG-1.tags_all
}

output "igw-name" {
    value = aws_internet_gateway.igw-for-cicd.tags_all
}

output "public-rt-name" {
    value = aws_route_table.public_rt_cicd.tags_all
}

output "vm-1-public-ip" {
    value = aws_instance.web-vms[0].ip
}

output "vm-1-tags" {
    value = aws_instance.web-vms[0].tags_all
}
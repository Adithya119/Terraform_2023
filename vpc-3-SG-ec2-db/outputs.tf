output "db-endpoint" {
    value = aws_db_instance.db-instance-1.endpoint
}

output "vpc_id" {
    value = aws_vpc.primary-vpc.id
}

output "db-subnet-group-name" {
    value = aws_db_subnet_group.db-subnet-1.name
}

output "web-server-1-public-ip" {
    value = aws_instance.web-server-1.public_ip
}

output "url-for-web-server-1" {
    value = format("http://%s", aws_instance.web-server-1.public_ip)
}

output "ssh_command" {
    value = format("ssh -i %s.pem ubuntu@%s", aws_key_pair.key2.key_name, aws_instance.web-server-1.public_ip)
}
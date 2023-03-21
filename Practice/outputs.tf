output "web-vm-1_public-ip" {
    value = aws_instance.web-vms[0].public_ip
}

output "url-for-web-vm-1" {
    value = format("http://%s", aws_instance.web-vms[0].public_ip)
}

# ssh -i key-2.pem ubuntu@ip
output "ssh_command" {
    value = format("ssh -i %s.pem ubuntu@%s", aws_key_pair.key-2.key_name, aws_instance.web-vms[0].public_ip)
}

output "db-endpoint" {
    value = terraform.workspace == "ST" ?aws_db_instance.ak-db-1.endpoint:""    ## notice that we deployed db only in ST
}

# ----
# output syntax is simlilar to variable
output "vpc_id" {                                   # syntax is similar to vars.tf
    value = aws_vpc.primary-vpc-2.id
}

output "web-vm-0_public_ip" {                        
    value = aws_instance.web-vms[0].public_ip
}

output "web-vm-1_public_ip" {                        
    value = terraform.workspace == "ST"?aws_instance.web-vms[1].public_ip:"N/A"
}

output "web-vm-0-ssh_command" {                             
    value = format("ssh -i %s.pem ubuntu@%s", aws_key_pair.key-3.key_name, aws_instance.web-vms[0].public_ip)
}

output "web-vm-1-ssh_command" {                             
    value = terraform.workspace == "ST"?format("ssh -i %s.pem ubuntu@%s", aws_key_pair.key-3.key_name, aws_instance.web-vms[1].public_ip):"N/A"
}
output "vpc_id" {                                   # syntax is similar to vars.tf
    value = aws_vpc.primary-vpc-2.id
}

output "web-vm-1_public_ip" {                        
    value = aws_instance.web-vms[0].public_ip
}

#output "web-vm-2_public_ip" {                        
 #   value = aws_instance.web-vms[1].public_ip
#}

output "ssh_command_for_vm-1" {                             # spaces are not accepted between words (should be like ssh_command)
    value = format("ssh -i %s.pem ubuntu@%s", aws_key_pair.key-3.key_name, aws_instance.web-vms[0].public_ip)
}

#output "ssh_command_for_vm-2" {                             
 #   value = format("ssh -i %s.pem ubuntu@%s", aws_key_pair.key-3.key_name, aws_instance.web-vms[1].public_ip)
#}
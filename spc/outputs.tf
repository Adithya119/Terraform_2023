output "vpc_id" {                                   # syntax is similar to vars.tf
    value = aws_vpc.primary-vpc-2.id
}

#output "spc-vm-1_public_ip" {                        
#    value = aws_instance.spc-vm-1.public_ip
#}

#output "ssh_command" {                             # spaces are not accepted between words (should be like ssh_command)
#    value = format("ssh -i %s.pem ubuntu@%s", aws_key_pair.key-3.key_name, aws_instance.spc-vm-1.public_ip)
#}
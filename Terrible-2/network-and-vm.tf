# 2 senarios used:
# using inv file with 2 remote node ip's  --> this is commented out in this page
# not using inv file but giving multiple ip's on CLI using the [count.index]

# on a separate note, you can actually do apache installation on remote nodes using cloud-init, thereby not using ansible at all.

data "aws_vpc" "default-vpc" {
    default = true
}


data "aws_subnet" "first-subnet" {
    vpc_id = "vpc-a06bbacb"
    cidr_block = "172.31.32.0/20"
}


data "aws_security_group" "open_all_SG" {           # you can directly give id or give the id in variable file to separate the variables
    id = "sg-0705ebd862427df7f"
}


resource "aws_key_pair" "key-3" {
    key_name = "key3"
    public_key = file(var.public-key)                       
}


resource "aws_instance" "web-vms" {
    count = 2
    ami = "ami-08ee6644906ff4d6c"          #ami-0851b76e8b1bce90b     #ami-08ee6644906ff4d6c
    instance_type = "t2.micro"
    vpc_security_group_ids = [data.aws_security_group.open_all_SG.id]        # referencing starts with data.
    subnet_id = data.aws_subnet.first-subnet.id
    associate_public_ip_address = true
    key_name = aws_key_pair.key-3.key_name

    tags = {
        Name = format("web-vm-%d", count.index)
    }
}


resource "null_resource" "deploy-apache2-using-ansible" {
    count = 2
    triggers = {                                         
        build_id = var.build_id
        vm-public-ips = aws_instance.web-vms[count.index].public_ip
    }

    connection {                                             # remember this as --->  ssh -i key3.pem ubuntu@<ip> 
        host = aws_instance.web-vms[count.index].public_ip
        private_key = file(var.private-key)
        type = "ssh"
        user = "ubuntu"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt update",
            "sudo apt install python3 -y",
        ]
    }

    #using inv file 
    #provisioner "local-exec" {
    #    command = "echo ${aws_instance.web-vms[count.index].public_ip} >> hosts"
    #}

    #provisioner "local-exec" {                                             # refer terraform doc for syntax
    #    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts apache2.yml -u ubuntu --private-key 'key3.pem'"
    #}

    provisioner "local-exec" {                                             # refer terraform doc for syntax
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${aws_instance.web-vms[count.index].public_ip},' apache2.yml -u ubuntu --private-key 'key3.pem'"
    }                                                                                             # comma right above here

    #depends_on = [
     # aws_instance.web-vms           # this did not make any difference. ?Doubt?
    #]
}
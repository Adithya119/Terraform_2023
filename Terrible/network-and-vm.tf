# parsing remote node's ip on CLI instead of using inv file.

data "aws_vpc" "default-vpc" {
    default = true
    # if you don't wanna choose default vpc, then just give:- id = var.vpc-id
}


data "aws_subnet" "first-subnet" {
    vpc_id = "vpc-a06bbacb"
    cidr_block = "172.31.32.0/20"
}


data "aws_security_group" "open_all_SG" {           # you can directly give ip or give the id in variable file
    id = "sg-0705ebd862427df7f"
}


resource "aws_key_pair" "key-3" {
    key_name = "key3"
    public_key = file(var.public-key)                       
}


resource "aws_instance" "vm-1" {
    ami = "ami-0851b76e8b1bce90b"
    instance_type = "t2.micro"
    vpc_security_group_ids = [data.aws_security_group.open_all_SG.id]        # referencing starts with data.
    subnet_id = data.aws_subnet.first-subnet.id
    associate_public_ip_address = true
    key_name = aws_key_pair.key-3.key_name

    tags = {
        Name = "web-vm-1"
    }
}


resource "null_resource" "deploy-apache2-using-ansible" {
    triggers = {                                         
        build_id = var.build_id
        vm-public-ip = aws_instance.vm-1.public_ip
    }

    connection {                                             # remember this as --->  ssh -i key3.pem ubuntu@<ip> 
        host = aws_instance.vm-1.public_ip
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

    provisioner "local-exec" {                                             # refer terraform doc for syntax
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${aws_instance.vm-1.public_ip},' apache2.yml -u ubuntu --private-key 'key3.pem'"
    }                                                                                     # comma right above

    depends_on = [
      aws_instance.vm-1
    ]
}
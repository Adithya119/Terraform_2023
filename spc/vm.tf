resource "aws_key_pair" "key-3" {
    key_name = "key3"
    public_key = file(var.public-key-3)                       # remember this as ---> file(key3.pub)
}


resource "aws_instance" "web-vms" {
    count = 2                                  # creating multiple resources requires "count" & [count.index]  That's it.
    ami = "ami-0851b76e8b1bce90b"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.Web-SG.id]        # not vpc_id      # Notice that it's plural because an instance can have multiple SG's attached to it => hence the use of list.
    subnet_id = aws_subnet.web-subnets[count.index].id    # [count.index] required for creating multiple vm's
    associate_public_ip_address = true
    key_name = aws_key_pair.key-3.key_name

    tags = {
        Name = var.web_vm_names[count.index]
    }
}


resource "aws_instance" "db-vms" {
    count = 4
    ami = "ami-0851b76e8b1bce90b"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.DB-SG.id]    # created in DB subnet for testing
    subnet_id = aws_subnet.db-subnets[count.index].id
    associate_public_ip_address = true
    key_name = aws_key_pair.key-3.key_name                    # one common key for multiple vm's

    tags = {
        Name = var.db_vm_names[count.index]
    }
}


resource "null_resource" "install_and_run_spc"{          # spaces are not accepted between words (should be like "install_and_run_spc"), no special characters.
    count = 2                                            # count
    triggers = {                                         # this trigger lets terraform to re-run only the provisioner, not the entire resource.     # triggers is an arguement by itself. Hence, definitely use "=" after triggers.
        build_id = var.build_id                          # build id can be received from github
        spc-vm-1-ip = aws_instance.web-vms[count.index].public_ip      #  this is required because let's say a change in subnet causes the server to be re-created but build_id trigger doesn't trigger the re-creation of null_resource.
    }

    connection {                                         # remember this as --->  ssh -i key3.pem ubuntu@<ip>           
        type = "ssh"
        private_key = file(var.private-key-3)
        user = var.username
        host = aws_instance.web-vms[count.index].public_ip
    }

    provisioner "file" {                                # copy operation using "file"
        source = "deploy-spc.sh"                         # file present on local. change the build_id everytime you modify the contents of this file.
        destination = "/home/ubuntu/deploy-spc.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /home/ubuntu/deploy-spc.sh",       # remember the comma
            "/home/ubuntu/deploy-spc.sh"
        ]
    }
}
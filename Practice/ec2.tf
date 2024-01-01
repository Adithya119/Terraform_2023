
resource "aws_key_pair" "key-2" {    # remember this resource
    key_name = "key-2"
    public_key = file(var.pub-key)  # file reads the contents of a file at the given path and returns them as a string.
}                                    # file(path)

resource "aws_instance" "web-vms" {
    count = terraform.workspace == "ST" ?2:1      ##
    ami = "ami-0851b76e8b1bce90b"
    instance_type = var.instance-types
    vpc_security_group_ids = [ aws_security_group.ssh-sg.id, aws_security_group.http-sg.id ]   # vpc is not required. This is enough.
    subnet_id = aws_subnet.web-subnets[count.index].id
    key_name = aws_key_pair.key-2.key_name
    associate_public_ip_address = true
    tags = {
        Name = format("%s-web-vm-%d", terraform.workspace, count.index)     ##
        Env = terraform.workspace
    }
}

resource "aws_instance" "db-vms" {
    count = terraform.workspace == "ST" ?2:1
    ami = "ami-0851b76e8b1bce90b"
    instance_type = var.instance-types
    vpc_security_group_ids = [aws_security_group.ssh-db-sg.id]   
    subnet_id = aws_subnet.db-subnets[count.index].id
    associate_public_ip_address = true
    key_name = aws_key_pair.key-2.key_name                    

    tags = {
        Name = format("%s-db-vm-%d", terraform.workspace, count.index),   
        Env = terraform.workspace
    }
}

resource "null_resource" "install-spc" {       # install spc on 2 vm's
    count = terraform.workspace == "ST" ?2:1  ##
    triggers = {
        build_id = var.build_id                        # trigger
    }

    connection {
        type = "ssh"
        user = var.user
        host = aws_instance.web-vms[count.index].public_ip
        private_key = file(var.private-key)
    }

    provisioner "file" {
        source = "deploy-spc.sh"                         # file present on local. change the build_id everytime you modify the contents of this file.
        destination = "/home/ubuntu/deploy-spc.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /home/ubuntu/deploy-spc.sh",
            "/home/ubuntu/deploy-spc.sh"
        ]
    }
}
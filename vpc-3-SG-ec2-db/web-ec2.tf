# creating a web server & null_resource (remote-exec)

resource "aws_key_pair" "key2" {
    key_name = "key2"
    public_key = file(var.key2-pub)  # file reads the contents of a file at the given path and returns them as a string.
}                                      # file(path)

resource "aws_instance" "web-server-1" {
    ami = "ami-0851b76e8b1bce90b"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.Web-SG.id]    # vpc is not required. This is enough.
    subnet_id = aws_subnet.subnets[0].id
    associate_public_ip_address = true
    key_name = aws_key_pair.key2.key_name
    tags = {
        Name = "Web-server-1"
    }
}

# null_resource   ---> provisioner is included inside null_resource & will be re-run only if build_id changes.
# with null_resource, a change in provisioner will not disturb the aws_instance.
resource "null_resource" "deploy-nginx" {
    triggers = {                                # triggers
        build_id = var.build_id
    }
    
    provisioner "remote-exec" {                 # remote-exec
        inline = [
            "sudo apt update",
            "sudo apt install nginx -y"
        ]
    }

    connection {
        type = "ssh"
        host = aws_instance.web-server-1.public_ip
        user = var.username
        private_key = file(var.key2-private)
    }
}
resource "aws_key_pair" "key-3" {
    key_name = "key3"
    public_key = file(var.public-key-3)                       
}


resource "aws_instance" "web-vms" {
    count = terraform.workspace == "ST" ?2:1                                  
    ami = "ami-0851b76e8b1bce90b"
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.Web-SG.id]       
    subnet_id = aws_subnet.web-subnets[count.index].id
    associate_public_ip_address = true
    key_name = aws_key_pair.key-3.key_name

    tags = {
        Name = format("%s-web-vm-%d", terraform.workspace, count.index),   # notice the comma   # %s -> string character;  %d -> decimal
        Env = terraform.workspace
    }
}


resource "aws_instance" "db-vms" {
    count = terraform.workspace == "ST" ?4:1
    ami = "ami-0851b76e8b1bce90b"
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.DB-SG.id]   
    subnet_id = aws_subnet.db-subnets[count.index].id
    associate_public_ip_address = true
    key_name = aws_key_pair.key-3.key_name                    

    tags = {
        Name = format("%s-db-vm-%d", terraform.workspace, count.index),   
        Env = terraform.workspace
    }
}


resource "null_resource" "install_and_run_spc"{          
    count = terraform.workspace == "ST" ?2:1                                            
    triggers = {                                         
        build_id = var.build_id                          
        web-vms-ip = aws_instance.web-vms[count.index].public_ip      
    }

    connection {                                             
        type = "ssh"
        private_key = file(var.private-key-3)
        user = var.username
        host = aws_instance.web-vms[count.index].public_ip
    }

    provisioner "file" {
        source = "deploy-spc.sh"                         
        destination = "/home/ubuntu/deploy-spc.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /home/ubuntu/deploy-spc.sh",       
            "/home/ubuntu/deploy-spc.sh"
        ]
    }
}
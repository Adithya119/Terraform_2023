
data "aws_key_pair" "key-1" {    # pulling existing key-pair --> hence used "data" block here
    key_name = "key1"  # optional
    filter {    # required
        name = "key-pair-id"
        values = ["key-09b50c94aa242c092"]     # plural --> hence the use of []
    }
}


data "template_cloudinit_config" "cloud-init-user-data" {    # this was working even with just --> data "cloudinit_config"
    part {
      content_type = "text/cloud-config"   # This is "required", opposed to what's mentioned in terraform registry   * * * 
      content = file("ansible-controller-cloud-config.yml")   
    # content = file("${path.module}/cloud-config.yaml") -->  ${path.module} points to current directory & it is not mandatory
  }
}
# cloud_init was successful after referring these 2 sites:-
#   https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config
#   https://www.sammeechward.com/cloud-init-and-terraform-with-aws


resource "aws_instance" "ansible-controller" {
    ami = "ami-0f8ca728008ff5af4"   # ubuntu 22
    instance_type = "t2.medium"
    associate_public_ip_address = true
    key_name = data.aws_key_pair.key-1.key_name             # since we are referring "data", use data.aws_key_pair  * * * * * 
    vpc_security_group_ids = [aws_security_group.SG-1.id]
    subnet_id = aws_subnet.subnets-cicd[count.index].id     # tricky [count.index].id       # ids --> plural
    user_data = data.template_cloudinit_config.cloud-init-user-data.rendered     # user_data
    tags = {
        name = "ansible-controller"
        #name = var.vm-names[count.index]   # var in tags as well --> vars can be used anywhere you want
    }    
}
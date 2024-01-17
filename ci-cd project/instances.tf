
data "aws_key_pair" "key-1" {    # pulling existing key-pair --> hence used "data" block here
    #key_name = "key1"  # optional
    filter {    # required
        name = "key-pair-id"
        values = ["key-09b50c94aa242c092"]     # plural --> hence the use of []
    }
}


#     ----------
# for ansible controller instance:-

# creating 2 ebs volumes:

resource "aws_ebs_volume" "ebs-1" {
    size = 8
    availability_zone = var.AZs[0]              # ebs volumes are only linked to AZ.
    tags = {
        name = "ansible-controller-xvdg"
    }
}

resource "aws_ebs_volume" "ebs-2" {
    size = 8
    availability_zone = var.AZs[0]
    tags = {
        name = "ansible-controller-xvdh"
    }
}


data "template_cloudinit_config" "cloud-init-ansible-controller" {    # this was working even with just --> data "cloudinit_config"
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
    key_name = data.aws_key_pair.key-1.key_name             # since we are referring "data" block, use data.aws_key_pair  * * * * * 
    vpc_security_group_ids = [aws_security_group.SG-1.id]
    subnet_id = aws_subnet.subnets-cicd[0].id     # tricky [count.index].id       # ids --> plural
    user_data = data.template_cloudinit_config.cloud-init-ansible-controller.rendered    # user_data
    user_data_replace_on_change = true  # When used in combination with user_data, this will trigger a destroy and recreate of instance when set to true
    tags = {
        name = "ansible-controller"
        #name = var.vm-names[count.index]   # var in tags as well --> vars can be used anywhere you want
    }    
}

# attaching the 2 ebs volumes to the instance:

resource "aws_volume_attachment" "vol-att-1" {
    device_name = "/dev/xvdg"
    volume_id = aws_ebs_volume.ebs-1.id
    instance_id = aws_instance.ansible-controller.id
}

resource "aws_volume_attachment" "vol-att-2" {
    device_name = "/dev/xvdh"
    volume_id = aws_ebs_volume.ebs-2.id
    instance_id = aws_instance.ansible-controller.id
}


# --------
# for remote nodes:
data "template_cloudinit_config" "cloud-init-ansible-nodes" {
    part {
        content_type = "text/cloud-config"
        content = file("ansible-nodes-cloud-config.yml")
    }
}


resource "aws_instance" "ansible-nodes" {
    ami = "ami-0f8ca728008ff5af4"
    instance_type = "t2.medium"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.SG-1.id]
    subnet_id = aws_subnet.subnets-cicd[1].id    # use no prefix for referencing to-be created resource blocks
    key_name = data.aws_key_pair.key-1.key_name  # user data.* as prefix for referencing existing resources
    user_data = data.template_cloudinit_config.cloud-init-ansible-nodes.rendered    # using data.* as prefix as the yml file already exists
    user_data_replace_on_change = true
    tags = {
        name = "ansible-remote-node"
    }
}
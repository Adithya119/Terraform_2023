
# RDS needs a subnet group for HA purpose

resource "aws_db_subnet_group" "subnet-group-2" {
    name = format("my-subnet-group-%s", lower(terraform.workspace))
    subnet_ids = [aws_subnet.subnets[2].id, aws_subnet.subnets[3].id]
}

resource "aws_db_instance" "ak-db-1" {
    count = terraform.workspace == "ST" ? 1:0      ##
    engine = "Postgres"
    instance_class = "db.t3.medium"
    vpc_security_group_ids = [ aws_security_group.ssh-db-sg.id ]     # vpc_id is not required. This is enough.
    db_subnet_group_name = aws_db_subnet_group.subnet-group-2.name
    identifier = "database-1"                  # name of the database which is visible in AWS UI
    #name = "adithyadb"                         # name of the database created inside the instance
    username = "adithya"      # give this in locals.tf so that users can enter it in CLI. Helps with confidentiality too.
    password = "adithya"      # give this in locals.tf so that users can enter it in CLI. Helps with confidentiality too.
}

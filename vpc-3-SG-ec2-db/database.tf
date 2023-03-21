resource "aws_db_subnet_group" "db-subnet-1" {
    name = "db-subnet-1"
    subnet_ids = [aws_subnet.subnets[2].id, aws_subnet.subnets[3].id]
}

resource "aws_db_instance" "db-instance-1" {
    allocated_storage = 20
    apply_immediately = true
    auto_minor_version_upgrade = false
    backup_retention_period = 0
    db_subnet_group_name = aws_db_subnet_group.db-subnet-1.name      # data is available within this file
    engine = "postgres"
    skip_final_snapshot = true
    identifier = "database-1"                  # name of the database which is visible in AWS UI
    instance_class = "db.t3.micro"
    multi_az = false
    name = "postgresDB"                         # name of the database created inside the instance
    username = "postgres"
    password = "postgres"
    vpc_security_group_ids = [aws_security_group.DB-SG.id]
}
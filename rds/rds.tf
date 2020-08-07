resource "aws_db_instance" "rds" {
  allocated_storage    = "${var.rds_allocated_storage}"
  storage_type         = "${var.rds_storage_type}"
  engine               = "${var.rds_engine}"
  engine_version       = "${var.rds_engine_version}"
  instance_class       = "${var.rds_instance_class}"
  name                 = "${var.project_name}_${var.env}_data_rds${var.rds_engine}"
  username             = "dbadmin"
  password             = "${var.rds_db_password}"
  multi_az             = false
  skip_final_snapshot  = true
  db_subnet_group_name = "${aws_db_subnet_group.rds_subnet.name}"
  identifier           = "${var.project_name}-${var.env}-data-rds${var.rds_engine}"
  vpc_security_group_ids = "${var.rds_vpc_security_group_ids}"

  tags {
    Project = "${var.project_name}"
    Env = "${var.env}"
    Type = "rds${var.rds_engine}"
    Component = "data"
    Name = "${var.project_name}-${var.env}-data-rds${var.rds_engine}"
  }
}
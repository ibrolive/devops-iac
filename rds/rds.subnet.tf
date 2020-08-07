resource "aws_db_subnet_group" "rds_subnet" {
  subnet_ids          = "${var.rds_subnet_ids}"
  name                = "${var.project_name}-${var.env}-data-rdssg"

  tags = {
    Project = "${var.project_name}"
    Env = "${var.env}"
    Type = "rdssg"
    Component = "data"
    Name = "${var.project_name}-${var.env}-data-rds"
  }
}
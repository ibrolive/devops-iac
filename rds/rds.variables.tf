variable "env" {
    description = "Environment name"
}

variable "project_name" {
  description = "Name of the project"
}

variable "rds_instance_class" {
  description = "RDS instance class"
}

variable "rds_storage_type" {
  description = "RDS storage type"
  default = "gp2"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage"
}

variable "rds_db_password" {
  description = "RDS DB Password"
}

variable "rds_subnet_ids" {
  type = "list"
  description = "RDS Subnet IDs"
}

variable "rds_vpc_security_group_ids" {
  type = "list"
  description = "RDS List of VPC security groups to associate"
}

variable "rds_engine" {
  description = "RDS The engine to use (postgres, mysql, etc)"
}

variable "rds_engine_version" {
  description = "RDS The engine version to use"
}

output "endpoint" {
  description = "DB Endpoint"
  value = "${aws_db_instance.rds.endpoint}"
}

output "port" {
  description = "DB port"
  value = "${aws_db_instance.rds.port}"
}

output "dbname" {
  description = "DB name"
  value = "${aws_db_instance.rds.name}"
}

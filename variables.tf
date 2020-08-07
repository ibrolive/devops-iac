# Variables common across all templates
variable "env" {
    description = "Name of environment, one of dev, sbx, impl or prod"
}
variable "gold_ami" {
    description = "AMI to be used for all the EC2 instances" 
}

variable "project_name" {
  description = "Name of the project"
}

variable "aws_account_number" {
  description = "AWS Account number"
}
variable "vpc_id" {
  description = "The VPC id"
}

# RDS variables
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

variable "rds_subnet_ids" {
  type = "list"
  description = "RDS Subnet IDs"
}

variable "rds_engine_version" {
  description = "RDS The engine version to use"
}

variable "rds_vpc_security_group_ids" {
  type = "list"
  description = "RDS List of VPC security groups to associate"
}

output "rds_db_url" {
  description = "Database URL"
  value =  "jdbc:postgresql://${module.rds.endpoint}/${module.rds.dbname}"
}

#ECS variables
variable "ecs_subnet_ids" {
  type        = "list"
  description = "The list of private subnets to place the instances in"
}
variable "ecs_lc_sg" {
  description = "The ECS launch configuration security group"
}

#S3 variable 
output "application_url" {
  description = "Frontend application URL"
  value =  "http://${module.s3.ui_bucket_endpoint}"
}


variable "api_port"{
  description ="tf_demo api application port"
  default= "3000"
}
variable "data_services_app_port"{
  description ="tf_demo data services application port"
  default= "3000"
}
variable "data_ingest_app_port" {
  description ="tf_demo data ingest application port"
  default= "3000"
}

# Provider 
provider "aws" {
    region = "us-east-1"
}

#Amazon Elastic Container Registry for tf_demo-api 
module "ecr" {
  source             = "./ecr"
  env                = "${var.env}"
  project_name       = "${var.project_name}"
  component = "api"
  aws_account_number = "${var.aws_account_number}"
}

#Amazon Elastic Container Registry for tf_demo-scan 
module "tf_demo-scan-ecr" {
  source             = "./ecr"
  env                = "${var.env}"
  project_name       = "${var.project_name}"
  component = "scan"
  aws_account_number = "${var.aws_account_number}"
}

#Amazon Elastic Container Registry for tf_demo-data-ingest
module "tf_demo-data-ingest-ecr" {
  source             = "./ecr"
  env                = "${var.env}"
  project_name       = "${var.project_name}"
  component = "dataingest"
  aws_account_number = "${var.aws_account_number}"
}

#Amazon Elastic Container Registry for tf_demo-data-services
module "tf_demo-data-services-ecr" {
  source             = "./ecr"
  env                = "${var.env}"
  project_name       = "${var.project_name}"
  component = "data-services"
  aws_account_number = "${var.aws_account_number}"
}

#AWS ECS container for tf_demo-api
module "tf_demo-api-ecs" {
  source           = "./ecs"  # module folder path
  env              = "${var.env}"
  project_name     = "${var.project_name}"
  component   = "api"
  gold_ami         = "${var.gold_ami}"
  ecs_asgProjectTag    = "${var.project_name}-api"
  vpc_id           = "${var.vpc_id}"
  ecs_launch_config_sg = "${var.ecs_lc_sg}"
  ecs_instance_profile_id = "tf_demo-EC2ContainerServiceforEC2Role"
  ecs_container_img ="${module.ecr.repository_url}:latest"
  ecs_container_port = 3000 
  ecs_subnet_ids ="${var.ecs_subnet_ids}"
  nlb_tg_port          =  80
  nlb_tg_protocol      =  "TCP"
  nlb_health_check_protocol = "TCP"
  nlb_listener_protocol =  "TCP"
  environment_variables = "[{ \"name\" : \"DATA_SERVICES_URL\", \"value\" : \"${module.tf_demo-data-services-ecs.nlb_dns_name}\" },{ \"name\" : \"ENV\", \"value\" : \"${var.env}\" },{ \"name\" : \"LISTEN_PORT\", \"value\" : \"${var.api_port}\" }]"
}

#AWS ECS cluster for tf_demo-data-services
module "tf_demo-data-services-ecs" {
  source           = "./ecs"  # module folder path
  env              = "${var.env}"
  project_name     = "${var.project_name}"
  component   = "data-services"
  gold_ami         = "${var.gold_ami}"
  ecs_asgProjectTag    = "${var.project_name}-dataservices"
  vpc_id           = "${var.vpc_id}"
  ecs_launch_config_sg = "${var.ecs_lc_sg}"
  ecs_instance_profile_id = "EC2ContainerServiceforEC2Role"
  ecs_container_img ="${module.tf_demo-data-services-ecr.repository_url}:latest"
  ecs_container_port = 3000 
  ecs_subnet_ids ="${var.ecs_subnet_ids}"
  nlb_tg_port          =  80
  nlb_tg_protocol      =  "TCP"
  nlb_health_check_protocol = "TCP"
  nlb_listener_protocol =  "TCP"
  environment_variables = "[{ \"name\" : \"AWS_CLEAN_BUCKET\", \"value\" : \"${module.s3.submissions_bucket}\" }, { \"name\" : \"ENV\", \"value\" : \"${var.env}\" },{ \"name\" : \"AWS_UPLOAD_BUCKET\", \"value\" : \"${module.s3.upload_bucket}\" },{ \"name\" : \"LISTEN_PORT\", \"value\" : \"${var.data_services_app_port}\" }]"

}

module "rds" {
  source = "./rds"
  env = "${var.env}"
  rds_instance_class = "${var.rds_instance_class}"
  rds_storage_type = "${var.rds_storage_type}"
  rds_allocated_storage = "${var.rds_allocated_storage}"
  rds_engine_version = "9.6.6"
  rds_db_password = "${var.rds_password}"
  rds_subnet_ids = "${var.rds_subnet_ids}"
  rds_vpc_security_group_ids = "${var.rds_vpc_security_group_ids}"
  project_name = "${var.project_name}"
  rds_engine = "postgres"
}

# module "ssm"{

#   source="./ssm" 
#   env                 = "${var.env}"
#   project_name        = "${var.project_name}" 
#   key_id              = "${var.key_id}"
#   from_email_address  = "${var.from_email_address}"
#   to_email_address    = "${var.to_email_address}"
#   smtp_password       = "${var.smtp_password}"
#   smtp_username       = "${var.smtp_username}"
#   api_secret          = "${var.api_secret}"
#   api_database_url    =  "postgresql:#${var.rds_username}:${var.rds_password}@${module.rds.endpoint}/${module.rds.dbname}"
#   api_username        = "${var.api_username}"
#   api_password        = "${var.api_password}"
#   api_port            = "${var.api_port}"
#   smtp_port_nm        = "${var.smtp_port_nm}" 
# }

#Calling sqs module to create SQS queue for submission upload
module "sub_upload_sqs" {
  source      = "./sqs"
  env         = "${var.env}"
  project_name= "${var.project_name}"
  component   = "scan-subupload"
  resourcetype = "sqs"
  queue_policy_actions = ["sqs:SendMessage", "sqs:ReceiveMessage"]
  #Below configuration values are default if we don't set it terraform will set default values, but we are still adding 
  #these properties, so that going forward we can adjust them. 
  visibility_timeout_seconds = 30     
  message_retention_seconds  = 345600 
  max_message_size           = 262144 
  delay_seconds              = 0      
  receive_wait_time_seconds  = 0    
}

#Calling sqs module to create SQS queue for scan results
module "scan_results_sqs" {
  source      = "./sqs"
  env         = "${var.env}"
  project_name     = "${var.project_name}"
  component   = "scan-results"
  resourcetype = "sqs" 
  queue_policy_actions = ["sqs:AddPermission"]
  #Below configuration values are default if we don't set it terraform will set default values, but we are still adding 
  #these properties, so that going forward we can adjust them. 
  visibility_timeout_seconds = 30     
  message_retention_seconds  = 345600 
  max_message_size           = 262144 
  delay_seconds              = 0      
  receive_wait_time_seconds  = 0       
}

module "s3" {
  source = "./s3"
  env = "${var.env}"
  project_name = "${var.project_name}"
  queue_arn  = "${module.sub_upload_sqs.queue_arn}"
  allowed_origins = ["http://tf_demo-${var.env}-ui-bucket.s3-website-us-east-1.amazonaws.com"]
}

module "tf_demo-scan-ecs" {
  source           = "./ecs"  # module folder path
  env              = "${var.env}"
  project_name     = "${var.project_name}"
  component   = "scan"
  gold_ami         = "${var.gold_ami}"
  ecs_asgProjectTag    = "${var.project_name}-scan"
  vpc_id           = "${var.vpc_id}"
  ecs_launch_config_sg = "${var.ecs_lc_sg}"
  ecs_instance_profile_id = "EC2ContainerServiceforEC2Role"
  ecs_container_img ="${module.tf_demo-scan-ecr.repository_url}:latest"
  ecs_container_port = 3000 #Some random port, because tf_demo-scan don't need a port mapping 
  ecs_subnet_ids = "${var.ecs_subnet_ids}"
  nlb_tg_port          = 80
  nlb_tg_protocol      =  "TCP"
  nlb_health_check_protocol = "TCP"
  nlb_listener_protocol=  "TCP"  
  environment_variables =  " [{ \"name\" : \"API_URL\", \"value\" : \"${module.tf_demo-api-ecs.nlb_dns_name}\" }, { \"name\" : \"ENV\", \"value\" : \"${var.env}\" }, { \"name\" : \"AWS_REGION\", \"value\" : \"us-east-1\" }, { \"name\" : \"AWS_SCAN_UPLOAD_QUEUE\", \"value\" : \"${module.sub_upload_sqs.queue_url}\" }, { \"name\" : \"AWS_CLEAN_BUCKET\", \"value\" : \"${module.s3.submissions_bucket}\" }, { \"name\" : \"AWS_QUARANTINE_BUCKET\", \"value\" : \"${module.s3.quarantine_bucket}\" }, { \"name\" : \"AWS_UPLOAD_BUCKET\", \"value\" : \"${module.s3.upload_bucket}\" }, { \"name\" : \"AWS_SCAN_RESULTS_QUEUE\", \"value\" : \"${module.scan_results_sqs.queue_url}\" } ]"       
}

module "tf_demo-data-ingest-ecs" {
  source           = "./ecs"  # module folder path
  env              = "${var.env}"
  project_name     = "${var.project_name}"
  component   = "dataingest"
  gold_ami         = "${var.gold_ami}"
  ecs_asgProjectTag    = "${var.project_name}-dataingest"
  vpc_id           = "${var.vpc_id}"
  ecs_launch_config_sg = "${var.ecs_lc_sg}"
  ecs_instance_profile_id = "EC2ContainerServiceforEC2Role"
  ecs_container_img ="${module.tf_demo-data-ingest-ecr.repository_url}:latest"
  ecs_container_port = 3000 
  ecs_subnet_ids ="${var.ecs_subnet_ids}"
  nlb_tg_port          =  80
  nlb_tg_protocol      =  "TCP"
  nlb_health_check_protocol = "TCP"
  nlb_listener_protocol =  "TCP"
  environment_variables = " [{ \"name\" : \"LISTEN_PORT\", \"value\" : \"${var.data_ingest_app_port}\" }, { \"name\" : \"API_URL\", \"value\" : \"${module.tf_demo-api-ecs.nlb_dns_name}\" }, { \"name\" : \"ENV\", \"value\" : \"${var.env}\" }, { \"name\" : \"AWS_CLEAN_BUCKET\", \"value\" : \"${module.s3.submissions_bucket}\" }, { \"name\" : \"AWS_SCAN_RESULTS_QUEUE\", \"value\" : \"${module.scan_results_sqs.queue_url}\" }]"
}
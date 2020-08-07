#Common variables
project_name = "qio"
gold_ami = "ami-747f360b" # RHEL_GOLD_VERSION_20_2018-06-18  

#Jenkins variables
jenkins_subnet="subnet-0120945c"
jenkins_sg="sg-9bfbc8ee"

#ECS cluster related variables
ecs_subnet_ids=["subnet-95398dc8", "subnet-9e0a72fa"]
vpc_id="vpc-7bd09d03"

#RDS variables
rds_allocated_storage=20
rds_subnet_ids = ["subnet-2b0d754f", "subnet-ce4afe93", "subnet-debec095", "subnet-a15cef8e"]
rds_instance_class="db.m4.large"
rds_engine_version="9.6.5"
rds_vpc_security_group_ids=["sg-9bfbc8ee"]

#ECS
ecs_lc_sg="sg-9bfbc8ee"

#Vault variables
terraform_vault_url="http://10.137.180.144:8200"
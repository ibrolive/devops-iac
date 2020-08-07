#Common variables
project_name = "qio"
gold_ami = "ami-747f360b" # RHEL_GOLD_VERSION_20_2018-06-18

#Jenkins variables
jenkins_subnet=""
jenkins_sg=""

#ECS cluster related variables
ecs_subnet_ids=["subnet-bd2591e0","subnet-ff7a029b"]
vpc_id="vpc-b5d69bcd"

#RDS variables
rds_allocated_storage=20
rds_subnet_ids = ["subnet-d122968c","subnet-a40a72c0","subnet-e647f4c9","subnet-e2a9d7a9"]
rds_instance_class="db.m4.large"
rds_engine_version="9.6.5"
rds_vpc_security_group_ids=["sg-19c8fb6c"]

#ECS
ecs_lc_sg="sg-19c8fb6c"

#Vault variables
terraform_vault_url="http://10.137.180.144:8200"
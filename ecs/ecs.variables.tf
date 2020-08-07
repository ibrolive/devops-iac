# Varaibles specific to the ECS template
variable "env" {
  description = "The name of the environment"
}
variable "project_name" {
  description = "The project name"
}
variable "vpc_id" {
  description = "The VPC id"
}
variable "ecs_subnet_ids" {
  type        = "list"
  description = "The list of private subnets to place the instances in"
}
variable "gold_ami" {
  description = "The AWS gold ami id to use"
}
variable "ecs_instance_profile_id" {
   description = "ECS Instance Profile Role ID"
}
variable "ecs_container_port" {
   description = "ECS container port"
   default     = 3000
}
variable "ecs_service_launch_type" {
   description = "ECS service Launch Type: EC2 or FARGATE"
   default     = "EC2"
}
variable "ecs_container_img" {
   description = "ECR repository name:Image tag"
}
variable "instance_type" {
  description = "AWS instance type to use"
  default = "m4.large"
}
variable "max_size" {
  default     = 1
  description = "Maximum size of the nodes in the cluster"
}
variable "min_size" {
  default     = 1
  description = "Minimum size of the nodes in the cluster"
}
variable "desired_capacity" {
  default     = 1
  description = "The desired capacity of the cluster"
}
variable "ecs_asgProjectTag" {
  description = "Project tag for Auto Scalling Group"
}
variable "ecs_container_cpu_units" {
  description = "The number of cpu units used by the ECS task"
  default     = 10
}
variable "ecs_container_memory" {
  description = "The amount (in MiB) of memory used by the task"
  default     = 2048
}
variable "nlb_tg_port" {
  description = "The port the load balancer uses when routing traffic to targets in target group"
  default     = 80
}
variable "nlb_tg_protocol" {
  description = "The protocol the load balancer uses when routing traffic to targets in target group (ex: HTTP, TCP)"
}
variable "nlb_health_check_path" {
  description = "The destination path for heath checks. This path must begin with a '/' character, and can be at most 1024 characters in length"
  default     = "/"
}
variable "nlb_health_check_protocol" {
  description = "The protocol the load balancer uses when performing health checks on targets in target group"
}
variable "nlb_listener_port" {
  description = "The port on which the load balancer is listening"
  default     = 80
}
variable "nlb_listener_protocol" {
  description = "The protocol for connections from clients to the load balancer"
}
variable "ecs_launch_config_sg" {
   description = "Security group for AWS launch configuration"
}
variable "environment_variables" {
  description ="Environment variables for ECS container"
}
variable "component" {
    description = "Application component this resource belongs to or a name that identifies the service the resource provides. Basically some thing that identifies the purpose of the resource. When the resource is very generic and is used across components, this can be omitted. E.g ui, api, scan, jenkins, sonarqube."
}

output "nlb_dns_name" {
   value = "http://${aws_alb.nlb.dns_name}"
}
#ECR related variables
variable "project_name" {
  description = "The name of the Elastic Container Registry(ECR)"
}
variable "env" {
  description = "The name of the environment"
}
variable "aws_account_number" {
  description = "The AWS account number"
}
variable "component" {
  description = "Application component this resource belongs to or a name that identifies the service the resource provides. Basically some thing that identifies the purpose of the resource. When the resource is very generic and is used across components, this can be omitted. E.g ui, api, scan, jenkins, sonarqube."
}
output "ecr_name" {
  value =  "${aws_ecr_repository.ecr.name}"
}
output "repository_url" {
  value =  "${aws_ecr_repository.ecr.repository_url}"
}
# Varaibles specific to the SQS queue
variable "env" {
  description = "The name of the environment"
}
variable "project_name" {
  description = "The project name"
}
variable "visibility_timeout_seconds" {
    description = "The length of time (in seconds) that a message received from a queue will be invisible to other receiving components. Value must be between 0 seconds and 12 hours."
}
variable "message_retention_seconds" {
    description = "The amount of time that Amazon SQS will retain a message if it does not get deleted. Value must be between 1 minute and 14 days."
}
variable "max_message_size" {
    description = "Maximum message size (in bytes) accepted by Amazon SQS. Value must be between 1 and 256 KB."
}
variable "delay_seconds" {
    description = "The amount of time to delay the first delivery of all messages added to this queue. Value must be between 0 seconds and 15 minutes."
}
variable "receive_wait_time_seconds" {
    description = "The maximum amount of time that a long polling receive call will wait for a message to become available before returning an empty response. Value must be between 0 and 20 seconds."
}
variable "queue_policy_actions" {
    type = "list"
    description = "The SQS queue policy actions"
}
variable "component" {
    description = "Application component this resource belongs to or a name that identifies the service the resource provides. Basically some thing that identifies the purpose of the resource. When the resource is very generic and is used across components, this can be omitted. E.g ui, api, scan, jenkins, sonarqube."
}
variable "resourcetype" {
    description = "A string representing the type of the resource. E.g. server, rds, bucket, sg, etc. Use a term that is easily identifiable and use it consistently"
}
output "queue_arn" {
    value = "${aws_sqs_queue.queue.arn}"
}
output "queue_url" {
    value = "${aws_sqs_queue.queue.id}"
}
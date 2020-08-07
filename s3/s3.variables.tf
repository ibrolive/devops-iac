# Varaibles specific to the S3 Bucket
variable "env" {
  description = "The name of the environment"
}

variable "project_name" {
  description = "Name of the project"
}

variable "queue_arn" {
  description = "The SQS queue arn"
}
variable "allowed_origins" {
  type = list(string)
  description = "Specifies which origins are allowed"
}
output "submissions_bucket" {
  value = "${aws_s3_bucket.submissions.id}"
}
output "quarantine_bucket" {
  value = "${aws_s3_bucket.sub_quarantine.id}"
}
output "upload_bucket" {
  value = "${aws_s3_bucket.sub_upload.id}"
}

output "ui_bucket_endpoint" {
  value = "${aws_s3_bucket.ui.website_endpoint}"
}
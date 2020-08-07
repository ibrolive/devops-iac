#Creating SQS queue for deliverables uploads
resource "aws_sqs_queue" "queue" {
  name                       = "${var.project_name}-${var.env}-${var.component}-sqsqueue"
  visibility_timeout_seconds = "${var.visibility_timeout_seconds}"
  message_retention_seconds  = "${var.message_retention_seconds}"
  max_message_size           = "${var.max_message_size}"
  delay_seconds              = "${var.delay_seconds}"
  receive_wait_time_seconds  = "${var.receive_wait_time_seconds}"

  tags {
    Project = "${var.project_name}"
    Env = "${var.env}"
    Type = "${var.resourcetype}"
    Component = "${var.component}"
    Name        = "${var.project_name}-${var.env}-${var.component}-sqsqueue"
  }
}
#Creating a policy and attaching to deliverables uploads
resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = "${aws_sqs_queue.queue.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${var.project_name}-${var.env}-${var.component}-sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["${join("\",\"", var.queue_policy_actions)}"],
      "Resource": "${aws_sqs_queue.queue.arn}"
    }
  ]
}
POLICY
}

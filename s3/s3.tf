#Creating S3 buckets
resource "aws_s3_bucket" "ui" {
  bucket          = "${var.project_name}-${var.env}-ui-bucket" //Using - instead of _, because _ doesn't allow the bucket to be exposesd as website
  acl             = "public-read"
  website {
    index_document  = "index.html"
    error_document =  "index.html"
  }  
  tags = {
    Env         = "${var.env}"
    Project     = "${var.project_name}"
    Name        = "${var.project_name}-${var.env}-ui-bucket"
    Type        = "bucket"
    Component   = "ui"
  }
}

#Creating s3 bucket for deliverable uploads
resource "aws_s3_bucket" "sub_upload" {
  bucket          = "${var.project_name}-${var.env}-sub_upload-bucket"
  acl             = "private"
  //CORS settings
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = "${var.allowed_origins}"
    expose_headers  = ["Access-Control-Allow-Origin"]
    max_age_seconds = 3000
  }
  tags = {
    Env         = "${var.env}"
    Project     = "${var.project_name}"
    Name        = "${var.project_name}-${var.env}-ui-bucket"
    Type        = "bucket"
    Component   = "ui"
  }
}

#Creating s3 bucket to put non-effected deliverable uploads
resource "aws_s3_bucket" "submissions" {
  bucket          = "${var.project_name}-${var.env}-submissions-bucket"
  acl             = "private"

  //CORS settings
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = "${var.allowed_origins}"
    expose_headers  = ["Access-Control-Allow-Origin"]
    max_age_seconds = 3000
  }

  tags = {
    Env         = "${var.env}"
    Project     = "${var.project_name}"
    Name        = "${var.project_name}-${var.env}-scan-bucket"
    Type        = "bucket"
    Component   = "scan"
  }
}

#Creating a SQS event for deliverable upload bucket, so that when objects get uploaded into bucket SQS will get notification
resource "aws_s3_bucket_notification" "bucket_notification" {  
  bucket = "${aws_s3_bucket.sub_upload.id}"

  queue {
    queue_arn     = "${var.queue_arn}"
    events        = ["s3:ObjectCreated:*"]
  }
}

#Creating s3 bucket to put effected deliverable uploads
resource "aws_s3_bucket" "sub_quarantine" {
  bucket          = "${var.project_name}-${var.env}-sub_quarantine-bucket"
  acl             = "private"
  tags = {
    Env         = "${var.env}"
    Project     = "${var.project_name}"
    Name        = "${var.project_name}-${var.env}-scan-bucket"
    Type        = "bucket"
    Component   = "scan"
  }
}
resource "aws_s3_bucket" "b" {
 bucket = "stackautomationbucketdavid"

 force_destroy = true
 
 logging {
   target_bucket = aws_s3_bucket.object_log_bucket.id
   target_prefix = "log/"
 }

}

resource "aws_s3_bucket_acl" "stack_bucket_acl" {
     bucket = aws_s3_bucket.b.id
     acl = "public-read-write"
 }

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.b.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "safeguard" {
  bucket = aws_s3_bucket.b.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-tf-log-bucket"
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "loggin_access" {
  bucket = aws_s3_bucket.b.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket" "object_log_bucket" {
  bucket = "object-level-logging-bucket"
  acl    = "log-delivery-write"
}
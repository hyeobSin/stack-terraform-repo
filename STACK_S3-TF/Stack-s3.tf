resource "aws_s3_bucket" "b" {
 bucket = "stackautomationbucketdavid"

 force_destroy = true

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
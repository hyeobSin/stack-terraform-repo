resource "aws_s3_bucket" "b" {
 bucket = "stackautomationbucketdavid"
 
 force_destroy=true

 tags = {
   OwnerEmail  = "magicsin@gmail"
   Environment = "Dev"
 }

 logging {
   target_bucket = aws_s3_bucket.object_log_bucket.id
   target_prefix = "log/"
 }
}

resource "aws_s3_bucket_accelerate_configuration" "speed_it_up" {
  bucket = aws_s3_bucket.b.bucket
  status = "Enabled"
}

resource "aws_s3_bucket_object" "test" {
  bucket = "stackautomationbucketdavid"
  key    = "new_object_key"
  source = "/home/sin/Desktop/StackIT/STS_COMMANDS"

  content_type = "text file"
  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("/home/sin/Desktop/StackIT/STS_COMMANDS")
}

resource "aws_s3_bucket" "object_log_bucket" {
  bucket = "object-level-logging-bucket"
  acl    = "log-delivery-write"
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

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
  redirect_all_requests_to {
    host_name = "www.example.com"
  }
}
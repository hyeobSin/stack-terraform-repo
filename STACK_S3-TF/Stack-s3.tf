resource "aws_s3_bucket" "b" {
 bucket = "stackautomationbucketdavid"

 force_destroy = true

}

resource "aws_s3_bucket_acl" "stack_bucket_acl" {
     bucket = aws_s3_bucket.b.id
     acl = "public-read-write"
 }

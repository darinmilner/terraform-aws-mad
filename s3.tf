resource "aws_s3_bucket" "powershellbucket" {
  bucket = "test-powershell-bucket-${var.region}"
}

resource "aws_s3_bucket_versioning" "upload-bucket-versioning" {
  bucket = aws_s3_bucket.powershellbucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_object" "scripts-folder" {
#   bucket = aws_s3_bucket.powershellbucket.id
#   acl    = "public-read"
#   key    = "psscript/"
# }

resource "aws_s3_bucket_ownership_controls" "s3-ownership" {
  bucket = aws_s3_bucket.powershellbucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.s3-ownership]

  bucket = aws_s3_bucket.powershellbucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.powershellbucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "VisualEditor0"
        Effect    = "Allow"
        Action    = "s3*"
        Principal = "*"
        Resource = [
          aws_s3_bucket.powershellbucket.arn,
          "${aws_s3_bucket.powershellbucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "static_assets" {
  bucket_prefix = var.bucket_prefix
  force_destroy = var.force_destroy

  tags = {
    Name    = "${var.project_name}-static-assets"
    Purpose = "static-assets"
  }
}

resource "aws_s3_bucket_versioning" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "static_assets" {
  count  = var.lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.static_assets.id

  rule {
    id     = "static-assets-retention"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_multipart_upload_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.static_assets]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "project_info" {
  bucket       = aws_s3_bucket.static_assets.id
  key          = "assets/project-info.txt"
  content_type = "text/plain"

  content = <<-EOF_ASSET
Project: ${var.project_name}
Purpose: Static asset storage for the Terraform webapp foundation
Classification: Private application asset
Managed by: Terraform
EOF_ASSET
}

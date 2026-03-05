terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

resource "random_id" "suffix" {
  byte_length = 4
}

# SERVIÇO 1 — Frontend (S3)
resource "aws_s3_bucket" "frontend" {
  bucket        = "dreamsquad-frontend-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document { suffix = "index.html" }
  error_document { key    = "error.html" }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket     = aws_s3_bucket.frontend.id
  depends_on = [aws_s3_bucket_public_access_block.frontend]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  content_type = "text/html"
  content      = <<-HTML
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
      <meta charset="UTF-8" />
      <title>DreamSquad</title>
      <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 60px; background: #f5f5f5; }
        h1   { color: #5b2d8e; }
        p    { color: #555; font-size: 1.1rem; }
        .badge { background: #5b2d8e; color: #fff; padding: 8px 20px; border-radius: 20px; display: inline-block; margin-top: 16px; }
      </style>
    </head>
    <body>
      <h1>🚀 DreamSquad</h1>
      <p>Frontend Estático servido via <strong>Amazon S3</strong></p>
      <div class="badge">Terraform ✔</div>
    </body>
    </html>
  HTML
}

terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  create_bucket = var.create_bucket
}

resource "aws_s3_bucket" "s3" {
	count = local.create_bucket ? 1 : 0
  bucket = var.bucket
	bucket_prefix = var.bucket_prefix 
  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "s3" {
  bucket = aws_s3_bucket.s3[0].id 
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
 }

resource "aws_s3_bucket_acl" "s3" {
  depends_on = [aws_s3_bucket_ownership_controls.s3]
  bucket = aws_s3_bucket.s3[0].id
  acl    = "private"
 }

 resource "aws_s3_bucket_versioning" "versioning" {
 ## count = local.create_bucket && length(keys(var.versioning)) > 0 ? 1 : 0
  bucket = aws_s3_bucket.s3[0].id
  expected_bucket_owner = var.expected_bucket_owner
  versioning_configuration {
    status = "Enabled"
    }
 }

 

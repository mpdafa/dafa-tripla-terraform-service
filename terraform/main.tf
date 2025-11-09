terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.25"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  node_groups = {
    default = {
      desired_capacity = 2
      instance_type    = "t3.medium"
    }
  }

  tags = {
    Environment = var.environment
  }
}

data "aws_canonical_user_id" "current" {}

# Bucket static_assets_dummy_1
resource "aws_s3_bucket" "static_assets_dummy_1" {
  bucket_prefix = "static-assets-dummy-1-"
  tags = {
      Env = "staging"
      }
}

output "bucket_name_dummy_1" {
  value = aws_s3_bucket.static_assets_dummy_1.bucket
}

resource "aws_s3_bucket_ownership_controls" "static_assets_dummy_1" {
  bucket = aws_s3_bucket.static_assets_dummy_1.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Bucket static_assets_dummy_2
resource "aws_s3_bucket" "static_assets_dummy_2" {
  bucket_prefix = "static-assets-dummy-2-"
  tags = {
      Env = "staging"
      }
}

output "bucket_name_dummy_2" {
  value = aws_s3_bucket.static_assets_dummy_2.bucket
}

resource "aws_s3_bucket_ownership_controls" "static_assets_dummy_2" {
  bucket = aws_s3_bucket.static_assets_dummy_2.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "static_assets_dummy_2" {
  bucket = aws_s3_bucket.static_assets_dummy_2.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "static_assets_dummy_2" {
  bucket = aws_s3_bucket.static_assets_dummy_2.id
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.static_assets_dummy_2,
    aws_s3_bucket_public_access_block.static_assets_dummy_2
  ]
}
## Bucket static_assets_static_assets_dummy_3
resource "aws_s3_bucket" "static_assets_static_assets_dummy_3" {
  bucket_prefix = "static-assets-dummy-3-"
  tags = {
      Env = "staging"
  }
}

output "bucket_name_static_assets_static_assets_dummy_3" {
  value = aws_s3_bucket.static_assets_static_assets_dummy_3.bucket
}

resource "aws_s3_bucket_ownership_controls" "static_assets_static_assets_dummy_3" {
  bucket = aws_s3_bucket.static_assets_static_assets_dummy_3.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

## Bucket static_assets_static_assets_dummy_4
resource "aws_s3_bucket" "static_assets_static_assets_dummy_4" {
  bucket_prefix = "static-assets-dummy-4-"
  tags = {
      Env = "staging"
  }
}

output "bucket_name_static_assets_static_assets_dummy_4" {
  value = aws_s3_bucket.static_assets_static_assets_dummy_4.bucket
}

resource "aws_s3_bucket_ownership_controls" "static_assets_static_assets_dummy_4" {
  bucket = aws_s3_bucket.static_assets_static_assets_dummy_4.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

## Bucket static_assets_static_assets_dummy_5
resource "aws_s3_bucket" "static_assets_static_assets_dummy_5" {
  bucket_prefix = "static-assets-dummy-5-"
  tags = {
      Env = "staging"
  }
}

output "bucket_name_static_assets_static_assets_dummy_5" {
  value = aws_s3_bucket.static_assets_static_assets_dummy_5.bucket
}

resource "aws_s3_bucket_ownership_controls" "static_assets_static_assets_dummy_5" {
  bucket = aws_s3_bucket.static_assets_static_assets_dummy_5.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "static_assets_static_assets_dummy_5" {
  bucket = aws_s3_bucket.static_assets_static_assets_dummy_5.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "static_assets_static_assets_dummy_5" {
  bucket = aws_s3_bucket.static_assets_static_assets_dummy_5.id
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.static_assets_static_assets_dummy_5,
    aws_s3_bucket_public_access_block.static_assets_static_assets_dummy_5
  ]
}


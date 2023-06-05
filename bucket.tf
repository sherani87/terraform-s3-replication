provider "aws" {
	profile = "default"  	
	region = local.source_region
}

provider "aws" {
	region = local.destination_region
	
	alias = "replica"
}

locals {
	source_bucket_name             = "test-source-${random_string.this.id}"
	destination_bucket_name        = "test-destination-${random_string.this.id}"
  	source_region    			 = "us-east-1"
 	destination_region          = "us-west-2"
}

data "aws_caller_identity" "current" {}

resource "random_string" "this" {
	length = 8
	lower = true
	upper = false
	special = false
	numeric = true
  }

module "replica_s3_bucket" {
	source = "./modules/"
	providers = {
		aws = aws.replica
	}
	bucket = local.destination_bucket_name 
	versioning = {
	enabled = "true"
	 }
	tags = {
		Name        = "Dev_Testing_Bucket"
		Environment = "Dev"
  }
}

module "source_s3_bucket" {
	source = "./modules/"
	bucket = local.source_bucket_name 
	versioning = {
	enabled = "true"
	 }
	tags = {
		Name = "Dev_Testing_Bucket"
		Environment = "Dev"
  		}		
 }

 resource "aws_s3_bucket_replication_configuration" "replication" {
 	bucket     = local.source_bucket_name
 	role = aws_iam_role.replication.arn
 	rule {
 		id     = "replication-rule"
 		filter {
 			prefix =  ""
 		  }
 		status = "Enabled"
##		delete_marker_replication = false
 		destination {
 			bucket  = "arn:aws:s3:::${local.destination_bucket_name}"
 			storage_class = "STANDARD"
 			}
 	}
 }

 

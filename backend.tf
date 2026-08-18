# Phase 1 (bootstrap): leave this commented out. `tofu init && tofu apply`
# runs with local state and creates the bucket.
#
# Phase 2 (migrate): uncomment, fill in the bucket name from
# `tofu output state_bucket` and the endpoint region, then run
# `tofu init -migrate-state`. See README.md for the full procedure.
#
# The backend reads Spaces credentials from AWS_ACCESS_KEY_ID /
# AWS_SECRET_ACCESS_KEY — set them to your Spaces keys. `region` is
# ignored by Spaces but required by the s3 backend; leave it us-east-1.

# terraform {
#   backend "s3" {
#     endpoints = {
#       s3 = "https://nyc3.digitaloceanspaces.com" # match the bucket's region
#     }
#
#     bucket = "REPLACE-WITH-state_bucket-OUTPUT"
#     key    = "bootstrap/terraform.tfstate"
#
#     region       = "us-east-1"
#     use_lockfile = true
#
#     skip_credentials_validation = true
#     skip_requesting_account_id  = true
#     skip_metadata_api_check     = true
#     skip_region_validation      = true
#     skip_s3_checksum            = true
#   }
# }

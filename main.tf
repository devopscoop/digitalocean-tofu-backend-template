locals {
  bucket_name = var.bucket_name != "" ? var.bucket_name : "${var.repo_name}-tfstate"
}

resource "digitalocean_spaces_bucket" "state" {
  name   = local.bucket_name
  region = var.region
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire-noncurrent-state-versions"
    enabled = true
    prefix  = ""

    noncurrent_version_expiration {
      days = var.noncurrent_version_expiration_days
    }

    abort_incomplete_multipart_upload_days = 7
  }

  # This bucket holds the state that describes it. Destroying it destroys
  # the record of everything in this configuration, so make `tofu destroy`
  # refuse to touch it unless this guard is removed first.
  lifecycle {
    prevent_destroy = true
  }
}

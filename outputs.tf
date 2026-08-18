output "state_bucket" {
  description = "Name of the state bucket."
  value       = digitalocean_spaces_bucket.state.name
}

output "state_bucket_region" {
  description = "Spaces region of the state bucket."
  value       = var.region
}

output "backend_config" {
  description = "Backend block for the repo's main configuration. Paste into its terraform {} block; adjust `key` if the repo has multiple root modules."
  value       = <<-EOT
    backend "s3" {
      endpoints = {
        s3 = "https://${var.region}.digitaloceanspaces.com"
      }

      bucket = "${digitalocean_spaces_bucket.state.name}"
      key    = "terraform.tfstate"

      region       = "us-east-1"
      use_lockfile = true

      skip_credentials_validation = true
      skip_requesting_account_id  = true
      skip_metadata_api_check     = true
      skip_region_validation      = true
      skip_s3_checksum            = true
    }
  EOT
}

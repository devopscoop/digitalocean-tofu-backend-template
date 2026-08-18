terraform {
  required_version = ">= 1.10"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  # Needs DIGITALOCEAN_TOKEN plus Spaces keys in SPACES_ACCESS_KEY_ID /
  # SPACES_SECRET_ACCESS_KEY. See README.md — the backend uses the same
  # Spaces keys but reads them from the AWS_* variable names.
}

variable "repo_name" {
  description = "Name of the git repository this state bucket belongs to. Used in the bucket name, so it must be bucket-name-safe (lowercase letters, digits, hyphens)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,40}[a-z0-9]$", var.repo_name))
    error_message = "repo_name must be 3-42 chars of lowercase letters, digits, and hyphens, starting and ending with a letter or digit."
  }
}

variable "region" {
  description = "Spaces region for the state bucket (e.g. nyc3, sfo3, ams3)."
  type        = string
  default     = "nyc3"
}

variable "bucket_name" {
  description = "Override for the bucket name. Leave empty to use '<repo_name>-tfstate'. Spaces bucket names are unique across all DigitalOcean customers, so a collision may force an override."
  type        = string
  default     = ""
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep noncurrent state versions before expiring them. Versioning is what lets you recover a clobbered state file, but old versions accumulate cost forever without this."
  type        = number
  default     = 90
}

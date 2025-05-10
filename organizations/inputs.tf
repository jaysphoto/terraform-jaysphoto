variable "organization_config_file" {
  description = "The path to the organization config file."
  type        = string
  default     = "sandbox_organizations.json"
}

variable "s3_config_bucket" {
  description = "The S3 bucket to store the sandbox organization JSON."
  type        = string
  default     = null
}

variable "s3_config_sandbox_key" {
  description = "The S3 key (path) to store the sandbox organization JSON."
  type        = string
  default     = "aws/organizations/sandbox/latest.json"
}

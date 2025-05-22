variable "organization_config_file" {
  description = "The path to the organization config file."
  type        = string
}

variable "s3_config_bucket" {
  description = "The S3 bucket to store the AWS organizations configuration."
  type        = string
  default     = null
}

variable "s3_config_key" {
  description = "The S3 key (path) to store the AWS organizations JSON file."
  type        = string
  default     = "aws/organizations/sandbox/latest.json"
}

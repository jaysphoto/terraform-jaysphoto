variable "bucket" {
  description = "The name of the S3 where terraform state files are stored"
  type        = string
  default     = ""
}

variable "key" {
  description = "The path in the S3 bucket where the terraform state files are stored"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region for terraform state S3 bucket"
  type        = string
  default     = ""
}

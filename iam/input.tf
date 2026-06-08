variable "dns_manager_user_name" {
    description = "The name of the IAM user for the DNS Manager."
    type = string
}

variable "route53_state_file_path" {
    description = "The Route53 terraform state file path with S3 backend configuration."
    type = string
    default = "../route53/.terraform/terraform.tfstate"
}

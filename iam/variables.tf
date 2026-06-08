variable "dns_manager_policy_name" {
  description = "The name of the IAM policy for the DNS manager"
  type        = string
  default     = null
}
variable "permissable_record_sets" {
  description = "DNS RRs that the DNS manager is allowed to modify"
  type = list(object({
    types = list(string)
    names = list(string)
  }))
  default = [
    {
      types = ["TXT"]
      names = ["homeassistant.jaysphoto.me", "*.homeassistant.jaysphoto.me"]
    }
  ]
}

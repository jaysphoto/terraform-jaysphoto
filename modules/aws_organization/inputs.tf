variable "organizational_unit" {
  description = "The sandbox project organization unit configuration."
  type        = object({
                  name                          = string
                  admin_role_name               = optional(string, "")
                  service_control_policy_name   = string
                  resource_control_policy_name  = string
                })
}

variable "ou_accounts" {
  description = "A map of sandbox projects to create in the organization."
  type        = map(object({
                  name  = string
                  email = string
                }))
}

variable "ou_account_policy_defaults" {
  description = "The default policies to attach to sandbox projects."
  type        = object({
                  service_control_policy_name   = string
                  resource_control_policy_name  = string
                })
}

variable "ou_account_policies" {
  description = "Map of sandbox project policies to attach."
  type        = map(object({
                  service_control_policy_names  = set(string)
                  resource_control_policy_names = set(string)
                }))
}

variable "additional_tags" {
  description = "Additional tags to apply to the resources."
  type        = map(string)
  default     = {}
}

variable "custom_rcps_by_name" {
  description = "A map of custom resource control policy IDs by name."
  type        = map(string)
  default     = {}
}

variable "custom_scps_by_name" {
  description = "A map of custom service control policy IDs by name."
  type        = map(string)
  default     = {}
}

variable "attach_default_ou_policy" {
  description = "Attach the default policy for OU accounts."
  type        = bool
  default     = true
}

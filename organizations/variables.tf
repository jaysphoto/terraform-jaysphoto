variable "sandbox_projects" {
  description = "A map of sandbox projects to create in the organization."
  type = map(object({
    name  = string
    email = string
  }))
}

variable "sandbox_project_organization_unit" {
  description = "The sandbox project organization unit configuration."
  type        = object({
    name  = string
    admin_role_name = string
    service_control_policy_name = string
    resource_control_policy_name = string
  })
}

variable "sandbox_projects_policy_defaults" {
  description = "The default policies to attach to sandbox projects."
  type = object({
    service_control_policy_name = string
    resource_control_policy_name = string
  })
}

variable "sandbox_projects_policies" {
  description = "Map of sandbox project policies to attach."
  type = map(object({
    service_control_policy_names = set(string)
    resource_control_policy_names = set(string)
  }))
  default = {}
}

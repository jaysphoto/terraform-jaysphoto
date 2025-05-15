
locals {  
  # From here on read the JSON organization config file and split into useful variables
  config            = jsondecode(file(var.organization_config_file))
  policy_documents  = lookup(local.config, "policy_documents", {})
}

# Customer-managed policiecs
resource "aws_organizations_policy" "customer_managed" {
  for_each = local.policy_documents

  name    = each.key
  content = file(each.value.file_path)
  type    = each.value.type
}

# Create Sandbox Environment OU and accounts
module "projects_sandbox" {
  source = "../modules/aws_organization"

  organizational_unit         = lookup(local.config, "sandbox_organization_unit", {})
  ou_accounts                 = lookup(local.config, "sandbox_projects", {})
  ou_account_policy_defaults  = lookup(local.config, "sandbox_projects_policy_defaults", {})
  ou_account_policies         = lookup(local.config, "sandbox_projects_policies", {})
  policy_documents            = local.policy_documents
  additional_tags             = lookup(local.config, "additional_tags", {})
  custom_rcps_by_name         = { for k, v in lookup(local.config, "policy_documents", {}) : k => aws_organizations_policy.customer_managed[k].id if v.type == "RESOURCE_CONTROL_POLICY" }
  custom_scps_by_name         = { for k, v in lookup(local.config, "policy_documents", {}) : k => aws_organizations_policy.customer_managed[k].id if v.type == "SERVICE_CONTROL_POLICY" }
}

# Store latest sandbox Organizations config
resource "aws_s3_object" "sandbox_organizations_latest_config" {
  count         = var.s3_config_bucket == null ? 0 : 1

  bucket        = var.s3_config_bucket
  key           = var.s3_config_sandbox_key
  source        = var.organization_config_file
  content_type  = "application/json"
}

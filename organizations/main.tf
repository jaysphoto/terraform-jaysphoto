
locals {
  # From here on read the JSON organization config file and split into useful variables
  config           = jsondecode(file(var.organization_config_file))
  policy_documents = lookup(local.config, "policy_documents", {})
  ou_accounts      = lookup(local.config, "projects", {})

  # AWS IAM Identity Center locals
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  permission_sets   = lookup(local.config, "permission_sets", {})
  group_permissions = lookup(local.config, "group_permissions", {})
  permission_sets_aws_managed = flatten([
    for k, ps in local.permission_sets : [
      for p in ps.managed_policies : { permission_set: k, policy: p }
    ]
  ])
  group_account_assignments = {
    for g, p in local.group_permissions :
      g => lookup(p.assignments, "all_accounts", false) ? keys(local.ou_accounts) : lookup(p.assignments, "accounts", [])
  }
  group_assignments = flatten([
    for g, p in local.group_permissions : [
      for a in local.group_account_assignments[g] : [
        for ps in p.permission_sets : [
          {
              principal_id   = g
              principal_type = "GROUP"
              account        = a
              permission_set = ps
          }
        ]
      ]
    ]
  ])
}

# Customer-managed policies
resource "aws_organizations_policy" "customer_managed" {
  for_each = local.policy_documents

  name    = each.key
  content = file(each.value.file_path)
  type    = each.value.type
}

# Create Sandbox Environment OU and accounts
module "projects_sandbox" {
  source = "../modules/aws_organization"

  organizational_unit        = lookup(local.config, "organization_unit", {})
  ou_accounts                = local.ou_accounts
  ou_account_policy_defaults = lookup(local.config, "projects_policy_defaults", {})
  ou_account_policies        = lookup(local.config, "projects_policies", {})
  additional_tags            = lookup(local.config, "additional_tags", {})
  custom_rcps_by_name        = { for k, v in local.policy_documents : k => aws_organizations_policy.customer_managed[k].id if v.type == "RESOURCE_CONTROL_POLICY" }
  custom_scps_by_name        = { for k, v in local.policy_documents : k => aws_organizations_policy.customer_managed[k].id if v.type == "SERVICE_CONTROL_POLICY" }
}

# AWS IAM Identity Center Permission Sets
resource "aws_ssoadmin_permission_set" "permission_set" {
  for_each = local.permission_sets

  name             = each.key
  description      = lookup(each.value, "description", null)
  instance_arn     = local.sso_instance_arn
  session_duration = lookup(each.value, "session_duration", var.default_sts_session_duration)
  tags             = lookup(each.value, "tags", {})
}

resource "aws_ssoadmin_managed_policy_attachment" "managed_policy" {
  for_each = { for p in local.permission_sets_aws_managed : "${p.permission_set}_${p.policy}" => p }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value.permission_set].arn
  managed_policy_arn = "arn:aws:iam::aws:policy/${each.value.policy}"
}

# AWS IAM Identity Store Groups
resource "aws_identitystore_group" "sso_group" {
  for_each = local.group_permissions

  display_name      = each.key
  description       = null
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
}

# AWS IAM Identity Center Group Permissions
resource "aws_ssoadmin_account_assignment" "groups" {
  for_each = { for ga in local.group_assignments : "${ga.principal_id}_${ga.principal_type}_${ga.account}_${ga.permission_set}" => ga }

  depends_on = [
    aws_ssoadmin_permission_set.permission_set,
    aws_identitystore_group.sso_group,
  ]

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value.permission_set].arn
  principal_id       = each.value.principal_type == "GROUP" ? aws_identitystore_group.sso_group[each.value.principal_id].group_id : each.value.principal_id
  principal_type     = each.value.principal_type
  target_id          = module.projects_sandbox.ou_accounts[each.value.account].id
  target_type        = "AWS_ACCOUNT"
}


# Store latest AWS Organizations config
resource "aws_s3_object" "sandbox_organizations_latest_config" {
  count = var.s3_config_bucket == null ? 0 : 1

  bucket       = var.s3_config_bucket
  key          = var.s3_config_key
  source       = var.organization_config_file
  content_type = "application/json"
}

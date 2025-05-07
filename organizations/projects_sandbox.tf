
# Organizational Root, -Unit and policty ids
data "aws_organizations_organization" "root" {}

locals {
  root_id = data.aws_organizations_organization.root.roots[0].id
  sandbox_resource_control_policy_name = var.sandbox_project_organization_unit.resource_control_policy_name
  sandbox_resource_control_policy_id = local.aws_organizations_rcps_by_name[local.sandbox_resource_control_policy_name]
  sandbox_service_control_policy_name = var.sandbox_project_organization_unit.service_control_policy_name
  sandbox_service_control_policy_id = local.aws_organizations_scps_by_name[local.sandbox_service_control_policy_name]
  default_sandbox_project_rcp_id = local.aws_organizations_rcps_by_name[var.sandbox_projects_policy_defaults.resource_control_policy_name]
  default_sandbox_project_scp_id = local.aws_organizations_scps_by_name[var.sandbox_projects_policy_defaults.service_control_policy_name]
  projects_sandbox_project_policies = {
    for project_policy in flatten([
      for index, project in var.sandbox_projects :
        concat([
          for name in lookup(var.sandbox_projects_policies[index], "service_control_policy_names", [local.default_sandbox_project_scp_id]) : {
            project_name = index
            policy_name = name
            policy_id = local.aws_organizations_scps_by_name[name]
            type = "service_control_policy"
          }],
          [
          for name in lookup(var.sandbox_projects_policies[index], "resource_control_policy_names", [local.default_sandbox_project_rcp_id]) : {
            project_name = index
            policy_name = name
            policy_id = local.aws_organizations_rcps_by_name[name]
            type = "resource_control_policy"
          }]
        )
    ]) : "${project_policy.project_name}_${project_policy.type}_${project_policy.policy_name}" => project_policy
  }
}

# Create the sand project organizational unit and attach policies
resource "aws_organizations_organizational_unit" "projects_sandbox" {
  name = var.sandbox_project_organization_unit.name
  parent_id = local.root_id
}

resource "aws_organizations_policy_attachment" "projects_sandbox_ou_rcp" {
  policy_id = local.sandbox_resource_control_policy_id
  target_id = aws_organizations_organizational_unit.projects_sandbox.id
}

resource "aws_organizations_policy_attachment" "projects_sandbox_ou_scp" {
  policy_id = local.sandbox_service_control_policy_id
  target_id = aws_organizations_organizational_unit.projects_sandbox.id
}

# Create the sandbox project accounts
resource "aws_organizations_account" "sandbox_projects" {
  for_each = var.sandbox_projects

  name  = each.value.name
  email = each.value.email

  parent_id = aws_organizations_organizational_unit.projects_sandbox.id
  role_name = var.sandbox_project_organization_unit.admin_role_name
  close_on_deletion = "true"

  tags = {
    Name = each.value.name
    Organization = aws_organizations_organizational_unit.projects_sandbox.name
    Environment = "Sandbox"
    Project = each.key
  }

  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}

# Attach project policies to the project AWS accounts
resource "aws_organizations_policy_attachment" "projects_sandbox_control_policy" {
  for_each = local.projects_sandbox_project_policies

  policy_id = each.value.policy_id
  target_id = aws_organizations_account.sandbox_projects["${each.value.project_name}"].id
}

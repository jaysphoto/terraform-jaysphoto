# Organizational Root, -Unit and policty ids
data "aws_organizations_organization" "root" {}

locals {
 root_id = data.aws_organizations_organization.root.roots[0].id
}

# Create the sand project organizational unit
resource "aws_organizations_organizational_unit" "organizational_unit" {
  name      = var.organizational_unit.name
  parent_id = local.root_id
  tags      = var.additional_tags
}

# Create the sandbox project accounts
resource "aws_organizations_account" "ou_account" {
  for_each = var.ou_accounts

  name  = each.value.name
  email = each.value.email

  parent_id = aws_organizations_organizational_unit.organizational_unit.id
  role_name = var.organizational_unit.admin_role_name
  close_on_deletion = "true"

  tags = merge({
    Name = each.value.name
    Organization = aws_organizations_organizational_unit.organizational_unit.name
  }, var.additional_tags)

  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}


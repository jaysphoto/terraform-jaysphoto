# Data sources for control policies in AWS Organizations
data "aws_organizations_policies" "service_control_policies" {
  filter = "SERVICE_CONTROL_POLICY"
}

data "aws_organizations_policy" "service_control_policy" {
  for_each  = toset(data.aws_organizations_policies.service_control_policies.ids)
  policy_id = each.value
}

data "aws_organizations_policies" "resource_control_policies" {
  filter = "RESOURCE_CONTROL_POLICY"
}

data "aws_organizations_policy" "resource_control_policy" {
  for_each  = toset(data.aws_organizations_policies.resource_control_policies.ids)
  policy_id = each.value
}

# Maps with Service- and Resource Control Policies by name
locals {
  default_ou_scp_name = "DefaultOUSCP"

  aws_organizations_rcps_by_name = merge(
    { for policy_id, policy in data.aws_organizations_policy.resource_control_policy : policy.name => policy_id },
    var.custom_rcps_by_name,
  )
  aws_organizations_scps_by_name = merge(
    { for policy_id, policy in data.aws_organizations_policy.service_control_policy : policy.name => policy_id },
    var.custom_scps_by_name,
  )

  sandbox_resource_control_policy_id    = local.aws_organizations_rcps_by_name[var.organizational_unit.resource_control_policy_name]
  sandbox_service_control_policy_id     = local.aws_organizations_scps_by_name[var.organizational_unit.service_control_policy_name]

  default_ou_account_rcp_id = local.aws_organizations_rcps_by_name[var.ou_account_policy_defaults.resource_control_policy_name]
  default_ou_account_scp_id = local.aws_organizations_scps_by_name[var.ou_account_policy_defaults.service_control_policy_name]

  # List of Customer SCP/RCP policies to attach to the OU accounts
  ou_account_policies = {
    for ou_account_policy in flatten([
      for index, project in var.ou_accounts :
        concat(
            [for name in lookup(var.ou_account_policies[index], "resource_control_policy_names", [local.default_ou_account_scp_id]) : {
              project_name  = index
              policy_name   = name
              policy_id     = local.aws_organizations_rcps_by_name[name]
              type          = "resource_control_policy"
            }],
            [for name in lookup(var.ou_account_policies[index], "service_control_policy_names", [local.default_ou_account_scp_id]) : {
              project_name  = index
              policy_name   = name
              policy_id     = local.aws_organizations_scps_by_name[name]
              type          = "service_control_policy"
            }]
        )
    ]) : "${ou_account_policy.project_name}_${ou_account_policy.type}_${ou_account_policy.policy_name}" => ou_account_policy
  }
}

# Define default OU Account policy
data "aws_iam_policy_document" "default_ou_policy" {
  statement {
    sid         = "DenyIamAccessAdminRole"
    effect      = "Deny"
    actions     = [
                    "iam:AttachRolePolicy",
                    "iam:DeleteRole",
                    "iam:DeleteRolePermissionsBoundary",
                    "iam:DeleteRolePolicy",
                    "iam:DetachRolePolicy",
                    "iam:PutRolePermissionsBoundary",
                    "iam:PutRolePolicy",
                    "iam:UpdateAssumeRolePolicy",
                    "iam:UpdateRole",
                    "iam:UpdateRoleDescription"
                  ]
     resources  = [
                    length(var.organizational_unit.admin_role_name) > 1 ? "arn:aws:iam::*:role/${var.organizational_unit.admin_role_name}" : ""
                  ]
  }

  statement {
    sid         = "DenyAwsOrganizationChanges"
    effect      = "Deny"
    actions     = [
                    "account:PutAccountName",
                    "organizations:UpdateOrganizationalUnit",
                    "organizations:LeaveOrganization"
                  ]
     resources  = ["*"]
  }
}

resource "aws_organizations_policy" "default_ou_policy" {
  name    = local.default_ou_scp_name
  content = data.aws_iam_policy_document.default_ou_policy.json
  type    = "SERVICE_CONTROL_POLICY"
}


# Attach policies to AWS Organizational Unit (OU)
resource "aws_organizations_policy_attachment" "organizational_unit_rcp" {
  policy_id = local.sandbox_resource_control_policy_id
  target_id = aws_organizations_organizational_unit.organizational_unit.id
}

resource "aws_organizations_policy_attachment" "organizational_unit_scp" {
  policy_id = local.sandbox_service_control_policy_id
  target_id = aws_organizations_organizational_unit.organizational_unit.id
}

resource "aws_organizations_policy_attachment" "organizational_unit_default_scp" {
  count  = var.attach_default_ou_policy ? 1 : 0

  policy_id = aws_organizations_policy.default_ou_policy.id
  target_id = aws_organizations_organizational_unit.organizational_unit.id
}

# Attach project policies to the project AWS accounts
resource "aws_organizations_policy_attachment" "ou_control_policy" {
  for_each = local.ou_account_policies

  policy_id = each.value.policy_id
  target_id = aws_organizations_account.ou_account["${each.value.project_name}"].id
}

# Create policy document for Assuming Admin access from root organization
data "aws_iam_policy_document" "grant_organization_admin_access" {
  count = length(var.organizational_unit.admin_role_name) > 0 ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    resources =  flatten([for org in aws_organizations_account.ou_account : "arn:aws:iam::${org.id}:role/${var.organizational_unit.admin_role_name}" ])

    condition {
      test = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values = ["true"]
    }
  }
}

# Attach the policy document to an IAM policy 
resource "aws_iam_policy" "projects_sandbox_admin_access_role_access_policy" {
  count = length(var.organizational_unit.admin_role_name) > 0 ? 1 : 0

  name    = "GrantAccessToOrganizationAccountAccessRole"
  path    = "/"
  policy  = data.aws_iam_policy_document.grant_organization_admin_access[0].json
}

# Customer-managed policiecs
resource "aws_organizations_policy" "customer_managed" {
  for_each = var.policy_documents

  name    = each.key
  content = file(each.value.file_path)
  type    = each.value.type
}

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
  aws_organizations_scps_by_name = merge(
    { for policy_id, policy in data.aws_organizations_policy.service_control_policy : policy.name => policy_id },
    { for k, v in aws_organizations_policy.customer_managed : v.name => v.id if v.type == "SERVICE_CONTROL_POLICY" }
  )
  aws_organizations_rcps_by_name = merge(
    { for policy_id, policy in data.aws_organizations_policy.resource_control_policy : policy.name => policy_id },
    { for k, v in aws_organizations_policy.customer_managed : v.name => v.id if v.type == "RESOURCE_CONTROL_POLICY" }
  )
}

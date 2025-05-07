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

locals {
  aws_organizations_scps_by_name = { for policy_id, policy in data.aws_organizations_policy.service_control_policy : policy.name => policy_id }
  aws_organizations_rcps_by_name = { for policy_id, policy in data.aws_organizations_policy.resource_control_policy : policy.name => policy_id }
}

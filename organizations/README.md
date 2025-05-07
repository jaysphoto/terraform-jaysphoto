
# Configure AWS organization structure
In `terraform.tfvars`:

```
sandbox_project_organization_unit = {
    name = "Project Sandbox"
    admin_role_name = "SandboxOrganizationAdminRole"
    service_control_policy_name = "FullAWSAccess"
    resource_control_policy_name = "RCPFullAWSAccess"
}

sandbox_projects = {
  "sandbox_project_1_dev" = {
    name  = "Sandbox Project 1 Dev"
    email = "sandbox_project+1_dev@example.com"
  }
}

sandbox_projects_policy_defaults = {
    service_control_policy_name = "FullAWSAccess"
    resource_control_policy_name = "RCPFullAWSAccess"
}

# Optional set policies per project
sandbox_projects_policies = {
    "sandbox_project_1_dev" = {
        service_control_policy_names = ["LimitedProjectSCP"]
    }
}

policy_documents = {
  "LimitedProjectSCP" = { file_path = "policies/limited_project_scp.json", type = "SERVICE_CONTROL_POLICY" },
  "SecureSandboxRCP" = { file_path = "policies/secure_sandbox_rcp.json", type = "RESOURCE_CONTROL_POLICY" }
}
```

# importing OU-ACCOUNT existing resources
Examples:
```
terraform import aws_organizations_organizational_unit.projects_sandbox ou-1234-12345678
terarform import aws_organizations_account.sandbox_projects["name"] 0123456789012
```

# importing existing policy attachments for the Sandbox OU and Project(-s)
Examples:
```
aws organizations list-policies-for-target --target-id ou-1234-12345678 --filter RESOURCE_CONTROL_POLICY
aws organizations list-policies-for-target --target-id ou-1234-12345678 --filter SERVICE_CONTROL_POLICY
terraform import aws_organizations_policy_attachment.projects_sandbox_ou_rcp ou-1234-12345678:p-RCPFullAWSAccess
terraform import aws_organizations_policy_attachment.projects_sandbox_ou_scp ou-1234-12345678:p-FullAWSAccess

aws organizations list-policies-for-target --target-id 0123456789012 --filter RESOURCE_CONTROL_POLICY
aws organizations list-policies-for-target --target-id 0123456789012 --filter SERVICE_CONTROL_POLICY
terraform import 'aws_organizations_policy_attachment.projects_sandbox_control_policy["sandbox_project_1_dev_resource_control_policy_RCPFullAWSAccess"]' 0123456789012:p-RCPFullAWSAccess
terraform import 'aws_organizations_policy_attachment.projects_sandbox_control_policy["sandbox_project_1_dev_service_control_policy_FullAWSAccess"]' 0123456789012:p-FullAWSAccess

```

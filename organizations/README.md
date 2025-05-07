
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
        service_control_policy_names = ["ProjectAWSRestricted"]
    }
}
```

# importing OU-ACCOUNT existing resources
Examples:
```
terraform import aws_organizations_organizational_unit.projects_sandbox ou-1234-12345678
terarform import aws_organizations_account.sandbox_projects["name"] 0123456789012
```

# importing existing policy attachments
Examples:
```
aws organizations list-policies-for-target --target-id ou-1234-12345678 --filter RESOURCE_CONTROL_POLICY
terraform import aws_organizations_policy_attachment.projects_sandbox_rcp ou-1234-12345678:p-RCPFullAWSAccess
```

```
aws organizations list-policies-for-target --target-id ou-1234-12345678 --filter SERVICE_CONTROL_POLICY
terraform import aws_organizations_policy_attachment.projects_sandbox_scp ou-1234-12345678:p-FullAWSAccess
```

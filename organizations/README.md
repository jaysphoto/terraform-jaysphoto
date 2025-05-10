

# Configuration
To managed the OU structures, a Json file with the desired structure is required

## Organization configurations
Organizational Unit and Account structure are read from a Json file; Optionally this configuration
is stored in the Admin Account's S3, by setting:

```
export TF_VARS_s3_config_bucket="terraform-jaysphoto-state"
export TF_VARS_s3_config_sandbox_key="aws/organizations"
```

The Sandbox OU configuration is stored in `s3://terraform-jaysphoto-state/aws/organizations/sandbox/latest.json`, for example.

# Importing resources

## Existing AWS Organizational Unit and/or Accounts
Examples:
```
terraform import aws_organizations_organizational_unit.projects_sandbox ou-1234-12345678
terarform import aws_organizations_account.sandbox_projects["name"] 0123456789012
```

## Existing Account policy attachments
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

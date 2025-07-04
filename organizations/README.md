

# Configuration
To create the AWS organizations, a Json file with the desired accounts and their configurations is required.

## Organization configurations
Organizational Unit and Account structure are read from a Json file, for example `example_organizations.json`:


```
{
    # AWS Organization structure
    "organization_unit": {
        "name": "Project Sandbox",
        "admin_role_name": "OrganizationAccountAccessRole",
        "service_control_policy_name": "FullAWSAccess",
        "resource_control_policy_name": "RCPFullAWSAccess"
    },
    "projects": {
        "project_1": {
            "name": "Project 1 Dev",
            "email": "project+1+dev@organization.com"
        }
    },
    "projects_policy_defaults": {
        "service_control_policy_name": "FullAWSAccess",
        "resource_control_policy_name": "RCPFullAWSAccess"
    },
    "projects_policies": {
        "project_1": {
            "service_control_policy_names": ["FullAWSAccess"],
            "resource_control_policy_names": ["RCPFullAWSAccess", "SecureSandboxRCP"]
        }
    },
    "policy_documents": {
        "LimitedProjectSCP": { "file_path": "policies/limited_project_scp.json", "type": "SERVICE_CONTROL_POLICY" },
        "SecureSandboxRCP": { "file_path": "policies/secure_sandbox_rcp.json", "type": "RESOURCE_CONTROL_POLICY" }
    },
    "additional_tags": {
        "Environment": "Dev",
        "Project": "Sandbox"
    },
    # AWS SSO configuration
    "permission_sets": {
        "AdministratorAccess":
            {
                "description": "Full account access permissions",
                "managed_policies": [
                    "arn:aws:iam::aws:policy/AdministratorAccess"
                ],
                "inline_policies": []
            },
        "PowerUserAccess":
            {
                "managed_policies": [
                    "arn:aws:iam::aws:policy/PowerUserAccess"
                ],
                "inline_policies": [],
                "session_duration": "PT4H"
            }
    },
    "group_permissions": {
        "Admins": {
            "permission_sets": ["AdministratorAccess"],
            "description": "Full access to manage the project and its resources.",
            "assignments": {
                "all_accounts": true
            }
        },
        "Boquercom": {
            "permission_sets": ["PowerUserAccess"],
            "description": "Access to manage Boquercom resources.",
            "assignments": {
                "accounts": ["project_1"]
            }
        }
    }
}
```

Optionally this configuration is persisted in an AWS S3 bucket when applied, by setting:

```
export TF_VARS_organization_config_file="example_organizations.json"
export TF_VARS_s3_config_bucket="terraform-jaysphoto-state"
export TF_VARS_s3_config_sandbox_key="aws/organizations"
```
or running `terraform plan` / `terraform apply` with:
```
terraform plan -var "organization_config_file=example_organizations.json" -var "s3_config_bucket=terraform-jaysphoto-state" -var "s3_config_sandbox_key=aws/organizations"
```

The Sandbox OU configuration will be stored in `s3://terraform-jaysphoto-state/aws/organizations/sandbox/latest.json`, in this example.

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

## Existing IAM Identity Center resources
Examples:

Listing Permission Sets:
```
aws sso-admin list-permission-sets --instance-arn arn:aws:sso:::instance/ssoins-123456789abcdef
aws sso-admin describe-permission-set --instance-arn arn:aws:sso:::instance/ssoins-123456789abcdef --permission-set-arn arn:aws:sso:::permissionSet/ssoins-123456789abcdef/ps-1111222233334444

terraform import 'aws_ssoadmin_permission_set.permission_set["AdministratorAccess"]' 'arn:aws:sso:::permissionSet/ssoins-123456789abcdef/ps-1111222233334444,arn:aws:sso:::instance/ssoins-123456789abcdef'

```

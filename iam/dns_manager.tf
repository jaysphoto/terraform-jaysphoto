locals {
    route53_state_json_data = jsondecode(file(var.route53_state_file_path))
    route53_state_s3_config = {
        for k, v in local.route53_state_json_data["backend"]["config"] : k => v  if contains(["bucket", "key", "region"], k)
    }
}

data "terraform_remote_state" "route53" {
  backend = "s3"

  config = local.route53_state_s3_config
}

data "aws_iam_policy_document" "allow_route53_lookups" {
    statement {
        actions = [
            "route53:GetChange",
            "route53:ListHostedZones",
        ]
        effect   = "Allow"
        resources = ["*"]
    }
    statement {
        actions = [
            "route53:GetHostedZone",
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets",
            "route53:ChangeResourceRecordSets",
        ]
        effect   = "Allow"
        resources = [data.terraform_remote_state.route53.outputs.route53_main_zone_arn]
    }
}

data "aws_iam_policy_document" "allow_route53_permissable_record_set_changes" {
    dynamic "statement" {
         for_each = var.permissable_record_sets
         content {
            actions = [
                "route53:ChangeResourceRecordSets"
            ]
            condition {
                test = "ForAllValues:StringEquals"
                variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
                values = statement.value.names
            }
            condition {
                test = "ForAllValues:StringEquals"
                variable = "route53:ChangeResourceRecordSetsRecordTypes"
                values = statement.value.types
            }
            effect   = "Allow"
            resources = [data.terraform_remote_state.route53.outputs.route53_main_zone_arn]
        }
    }
}

data "aws_iam_policy_document" "combined_policy" {
    source_policy_documents = concat([
        data.aws_iam_policy_document.allow_route53_lookups.json,
        data.aws_iam_policy_document.allow_route53_permissable_record_set_changes.json,
    ])
}

resource "aws_iam_user_policy" "dns_manager_policy" {
  name = var.dns_manager_policy_name == null ? "${var.dns_manager_user_name}_dns_manager" : var.dns_manager_policy_name
  user = aws_iam_user.dns_manager_user.name
  policy = data.aws_iam_policy_document.combined_policy.json
}

resource "aws_iam_user" "dns_manager_user" {
  name = var.dns_manager_user_name
  path = "/"
}

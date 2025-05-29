# This content is copied from https://github.com/aws-ia/terraform-aws-permission-sets
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_organizations_organization" "org" {}

data "aws_ssoadmin_instances" "sso" {}

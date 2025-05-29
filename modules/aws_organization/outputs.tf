output "organization_arn" {
  value = aws_organizations_organizational_unit.organizational_unit.arn
}

output "ou_accounts" {
  value = {
    for k, account in var.ou_accounts :
        k => {
            id        = aws_organizations_account.ou_account[k].id,
            arn       = aws_organizations_account.ou_account[k].arn,
            name      = aws_organizations_account.ou_account[k].name,
            email     = aws_organizations_account.ou_account[k].email,
            parent_id = aws_organizations_account.ou_account[k].parent_id,
        }
  }
}

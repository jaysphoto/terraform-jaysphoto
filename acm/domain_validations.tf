resource "aws_acm_certificate" "legacy" {
  domain_name               = "jayhaabee.nl"
  subject_alternative_names = ["plex.jayhaabee.nl", "media.jayhaabee.nl"]
  validation_method         = "DNS"
}

data "aws_route53_zone" "legacy" {
  name         = "jayhaabee.nl"
  private_zone = false
}

resource "aws_route53_record" "legacy_domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.legacy.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.legacy.zone_id
}

resource "aws_acm_certificate_validation" "legacy" {
  certificate_arn         = aws_acm_certificate.legacy.arn
  validation_record_fqdns = [for record in aws_route53_record.legacy_domain_validation : record.fqdn]
}

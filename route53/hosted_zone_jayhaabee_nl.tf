resource "aws_route53_zone" "legacy" {
  name    = "jayhaabee.nl"
}

module "legacy-records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = "Z7ESQH1GGCJR7"

  records = [
    {
      name = ""
      ttl  = 300
      type = "MX"
      records = var.gmail_mx_records
    },
    {
      name = ""
      ttl  = 300
      type = "TXT"
      records = [
        "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQD3PPtQJbwjYDhfV4M2r8ZBYYp6wF0FqeBE8bNQV2NnamnsppTWO/MD90OxAr9kgwvtflB5POQzR40UyCnFpK2X7Se9hPOdmEhfmHTCT3h7uwywuH2y/Ho05brcw7AnAMiimcV9MuIth201NH0Q++jQIsD57iA/VAI+dGIjOqAyzQIDAQAB",
        "v=spf1 include:_spf.google.com ~all"
      ]
    },
    {
      name  = "localhost",
      ttl   = 86400
      type  = "A"
      records = ["127.0.0.1"]
    },
    {
      name  = "plex",
      ttl   = 86400
      type  = "A"
      records = ["54.76.154.28"]
    },
    {
      name  = "media",
      ttl   = 86400
      type  = "A"
      records = ["54.76.154.28"]
    }
  ]
}

/*
ResourceRecordSets:
- Name: jayhaabee.nl.
  ResourceRecords:
  - Value: 10 aspmx.l.google.com.
  - Value: 20 alt1.aspmx.l.google.com.
  - Value: 50 aspmx3.googlemail.com.
  - Value: 50 aspmx2.googlemail.com.
  - Value: 20 alt2.aspmx.l.google.com.
  TTL: 180
  Type: MX
- Name: jayhaabee.nl.
  ResourceRecords:
  - Value: ns-1316.awsdns-36.org.
  - Value: ns-850.awsdns-42.net.
  - Value: ns-1850.awsdns-39.co.uk.
  - Value: ns-237.awsdns-29.com.
  TTL: 172800
  Type: NS
- Name: jayhaabee.nl.
  ResourceRecords:
  - Value: ns-1316.awsdns-36.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600
      86400
  TTL: 900
  Type: SOA
- Name: jayhaabee.nl.
  ResourceRecords:
  - Value: ns-1316.awsdns-36.org.
  - Value: ns-850.awsdns-42.net.
  - Value: ns-1850.awsdns-39.co.uk.
  - Value: ns-237.awsdns-29.com.
  TTL: 172800
  Type: NS
- Name: jayhaabee.nl.
  ResourceRecords:
  - Value: ns-1316.awsdns-36.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600
      86400
  TTL: 900
  Type: SOA
- Name: jayhaabee.nl.
  ResourceRecords:
  - Value: '"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDUST2y+cd9wzGYW9OHfdNjIBdHqMjCRWnMch1yTOVzB/v9RWvBtirYerBTNfh0e
L13fk9l07PHvm3FTVlvpx1RbXhbZbaE4jkACkiASZW/KiBiXTXefGpjS1vFsfK0gHvCTOi6E7VM22wFWJn2lp5SnKwMr8y7d9rhvjjr38SRTwIDAQAB"'
  - Value: '"v=spf1 a include:_spf.google.com ~all"'
  TTL: 86400
  Type: TXT
- Name: home.jayhaabee.nl.
  ResourceRecords:
  - Value: 82.197.212.157
  TTL: 86400
  Type: A
- Name: localhost.jayhaabee.nl.
  ResourceRecords:
  - Value: 127.0.0.1
  TTL: 86400
  Type: A
- Name: media.jayhaabee.nl.
  ResourceRecords:
  - Value: 54.76.154.28
  TTL: 86400
  Type: A
- Name: _168ef659ad659a56d2fada545e4264a7.media.jayhaabee.nl.
  ResourceRecords:
  - Value: _163c17ff5230af8bf2aab29a612e06d0.duyqrilejt.acm-validations.aws.
  TTL: 300
  Type: CNAME
- Name: plex.jayhaabee.nl.
  ResourceRecords:
  - Value: 54.76.154.28
  TTL: 86400
  Type: A
- Name: _f6a1798e486e61e955352b2961e2eb65.plex.jayhaabee.nl.
  ResourceRecords:
  - Value: _404280e878985ef1714a25cbda80004f.duyqrilejt.acm-validations.aws.
  TTL: 300
  Type: CNAME
*/

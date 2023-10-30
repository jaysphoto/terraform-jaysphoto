resource "aws_route53_zone" "main" {
  name    = "jaysphoto.me"
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = "Z7HSDEOJF8RTN"

  records = [
    {
      name = ""
      ttl  = 300
      type = "MX"
      records = var.gmail_mx_records
    },
    {
      name = ""
      ttl  = 86400
      type = "TXT"
      records = [
        "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQD3PPtQJbwjYDhfV4M2r8ZBYYp6wF0FqeBE8bNQV2NnamnsppTWO/MD90OxAr9kgwvtflB5POQzR40UyCnFpK2X7Se9hPOdmEhfmHTCT3h7uwywuH2y/Ho05brcw7AnAMiimcV9MuIth201NH0Q++jQIsD57iA/VAI+dGIjOqAyzQIDAQAB",
        "v=spf1 a include:_spf.google.com ~all"
      ]
    },
    {
      name = "google._domainkey"
      ttl  = 300
      type = "TXT"
      records = [
        "google-site-verification=mMHPKq6hhqUlb2I0odZRNKyhkBr1PJvLmTeh3WImWoA"
      ]
    },
    {
      name  = "localhost",
      ttl   = 86400
      type  = "A"
      records = ["127.0.0.1"]
    }
  ]
}

/*
ResourceRecordSets:
- Name: jaysphoto.me.
  ResourceRecords:
  - Value: ns-179.awsdns-22.com.
  - Value: ns-1300.awsdns-34.org.
  - Value: ns-598.awsdns-10.net.
  - Value: ns-2032.awsdns-62.co.uk.
  TTL: 172800
  Type: NS
- Name: jaysphoto.me.
  ResourceRecords:
  - Value: ns-179.awsdns-22.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600
      86400
  TTL: 900
  Type: SOA
*/

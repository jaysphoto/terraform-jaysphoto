variable "gmail_mx_records" {
  type = list(string)
  default = [
    "10 aspmx.l.google.com.",
    "20 alt1.aspmx.l.google.com.",
    "20 alt2.aspmx.l.google.com.",
    "50 aspmx2.googlemail.com.",
    "50 aspmx3.googlemail.com.",
  ]
}

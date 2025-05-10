output "bootstrap_bucket" {
    value = aws_s3_bucket.bootstrap_s3_bucket.bucket
}

output "bootstrap_bucket_key" {
    value = dirname("${var.key}")
}

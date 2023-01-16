output "app_live_url" {
  value = "https://${aws_route53_record.app_dns_record.fqdn}"
}

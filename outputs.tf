output "web_acl_id" {
  value = "${aws_waf_web_acl.waf_web_acl.id}"
}

output "bad_bad_protection_honeypot_endpoint_url" {
  description = "The honeypot endpoint URL which can be embedded in to web content"
  value = "${module.bad_bot_protection.bad_bad_protection_honeypot_endpoint_url}"
}
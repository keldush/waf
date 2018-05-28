output "bad_bot_protection_waf_rule_id" {
  description = "The ID of the rule which will be automatically added to by the bad bot protection module. If the module is disabled, the rule will be created but never contain any IPs"
  value = "${aws_waf_rule.waf_auto_block_rule.id}"
}

output "bad_bad_protection_honeypot_endpoint_url" {
  description = "The honeypot endpoint URL which can be embedded in to web content"
  value = "${aws_api_gateway_deployment.example.*.invoke_url}"
}
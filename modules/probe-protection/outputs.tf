output "probe_protection_waf_rule_id" {
  description = "The ID of the rule which will be automatically added to by the probe protection module. If the module is disabled, the rule will be created but never contain any IPs"
  value = "${aws_waf_rule.waf_auto_block_rule.id}"
}
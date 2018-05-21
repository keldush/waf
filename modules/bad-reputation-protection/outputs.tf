output "bad_reputation_waf_rule_id" {
  description = "The ID of the first rule which will be automatically added to by the bad reputation protection module. If the module is disabled, the rule will be created but never contain any IPs"
  value = "${aws_waf_rule.waf_auto_block_rule.id}"
}

output "bad_reputation_waf_rule2_id" {
  description = "The ID of the second rule which will be automatically added to by the bad reputation protection module. If the module is disabled, the rule will be created but never contain any IPs"
  value = "${aws_waf_rule.waf_auto_block_rule2.id}"
}
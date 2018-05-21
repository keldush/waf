output "flood_protection_waf_rule_id" {
  value = "${aws_waf_rate_based_rule.waf_flood_protection_rule.id}"
}
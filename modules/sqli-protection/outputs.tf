output "sqli_protection_waf_rule_id" {
  description = "The ID of the SQLI protection rule."
  value = "${aws_waf_rule.waf_sqli_rule.id}"
}
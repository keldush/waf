output "xss_protection_waf_rule_id" {
  description = "The ID of the XSS protection rule."
  value = "${aws_waf_rule.waf_xss_rule.id}"
}
output "request_size_protection_waf_rule_id" {
  description = "The ID of the request size protection rule."
  value = "${aws_waf_rule.waf_size_rule.id}"
}
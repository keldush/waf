output "bad_request_protection_waf_rule_id" {
  description = "The ID of the bad request protection rule."
  value = "${aws_waf_rule.waf_bad_requests_rule.id}"
}
output "paths_rule_id" {
  value = "${aws_waf_rule.waf_paths_rule.id}"
}

output "privileged_rule_id" {
  value = "${aws_waf_rule.waf_privileged_rule.id}"
}

output "size_rule_id" {
  value = "${aws_waf_rule.waf_size_rule.id}"
}

output "sqli_rule_id" {
  value = "${aws_waf_rule.waf_sqli_rule.id}"
}

output "webroot_rule_id" {
  value = "${aws_waf_rule.waf_weboot_rule.id}"
}

output "xss_rule_id" {
  value = "${aws_waf_rule.waf_xss_rule.id}"
}

resource "aws_waf_rule" "waf_privileged_rule" {
  depends_on = ["aws_waf_byte_match_set.waf_privileged_match_set"]
  name = "waf_privileged_rule"
  metric_name = "WafPrivilegedRule"
  predicates {
    data_id = "${aws_waf_byte_match_set.waf_privileged_match_set.id}"
    negated = false
    type = "ByteMatch"
  }
}
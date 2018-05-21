resource "aws_waf_rule" "waf_weboot_rule" {
  depends_on = ["aws_waf_byte_match_set.waf_webroot_match_set"]
  name = "waf_paths_rule"
  metric_name = "WafWebrootRule"
  predicates {
    data_id = "${aws_waf_byte_match_set.waf_webroot_match_set.id}"
    negated = false
    type = "ByteMatch"
  }
}
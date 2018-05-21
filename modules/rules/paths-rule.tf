resource "aws_waf_rule" "waf_paths_rule" {
  depends_on = ["aws_waf_byte_match_set.waf_paths_match_set"]
  name = "waf_paths_rule"
  metric_name = "WafPathTraversalRule"
  predicates {
    data_id = "${aws_waf_byte_match_set.waf_paths_match_set.id}"
    negated = false
    type = "ByteMatch"
  }
}
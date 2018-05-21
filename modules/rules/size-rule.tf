resource "aws_waf_rule" "waf_size_rule" {
  depends_on = ["aws_waf_size_constraint_set.waf_size_match_set"]
  name = "waf_size_rule"
  metric_name = "WafSizeRule"
  predicates {
    data_id = "${aws_waf_size_constraint_set.waf_size_match_set.id}"
    negated = false
    type = "SizeConstraint"
  }
}
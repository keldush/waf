## Mitigate abnormal requests via size restrictions
## Enforce consistent request hygiene, limit size of key elements
## Taken from: https://github.com/aws-samples/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml

resource "aws_waf_size_constraint_set" "waf_size_match_set" {
  name = "waf_size_match_set"

  size_constraints {
    comparison_operator = "GT"
    "field_to_match" {
      type = "URI"
    }
    size = "${var.max_uri_size}"
    text_transformation = "NONE"
  }

  size_constraints {
    comparison_operator = "GT"
    "field_to_match" {
      type = "QUERY_STRING"
    }
    size = "${var.max_query_string_size}"
    text_transformation = "NONE"
  }

  size_constraints {
    comparison_operator = "GT"
    "field_to_match" {
      type = "BODY"
    }
    size = "${var.max_body_size}"
    text_transformation = "NONE"
  }

  size_constraints {
    comparison_operator = "GT"
    "field_to_match" {
      type = "HEADER"
      data = "cookie"
    }
    size = "${var.max_cookie_size}"
    text_transformation = "NONE"
  }
}

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
## OWASP Top 10 A3
## Mitigate Cross Site Scripting Attacks
## Matches attempted XSS patterns in the URI, QUERY_STRING, BODY, COOKIES
## Taken from: https://github.com/aws-samples/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml

resource "aws_waf_xss_match_set" "waf_xss_match_set" {
  name = "waf_xss_match_set"

  xss_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    text_transformation = "URL_DECODE"
  }

  xss_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    text_transformation = "HTML_ENTITY_DECODE"
  }

  xss_match_tuples {
    "field_to_match" {
      type = "QUERY_STRING"
    }
    text_transformation = "URL_DECODE"
  }

  xss_match_tuples {
    "field_to_match" {
      type = "QUERY_STRING"
    }
    text_transformation = "HTML_ENTITY_DECODE"
  }

  xss_match_tuples {
    "field_to_match" {
      type = "BODY"
    }
    text_transformation = "URL_DECODE"
  }

  xss_match_tuples {
    "field_to_match" {
      type = "BODY"
    }
    text_transformation = "HTML_ENTITY_DECODE"
  }

  xss_match_tuples {
    "field_to_match" {
      type = "HEADER"
      data = "cookie"
    }
    text_transformation = "URL_DECODE"
  }

  xss_match_tuples {
    "field_to_match" {
      type = "HEADER"
      data = "cookie"
    }
    text_transformation = "HTML_ENTITY_DECODE"
  }
}

resource "aws_waf_rule" "waf_xss_rule" {
  depends_on = ["aws_waf_xss_match_set.waf_xss_match_set"]
  name = "XSS Rule"
  metric_name = "WafXssRule"
  predicates {
    data_id = "${aws_waf_xss_match_set.waf_xss_match_set.id}"
    negated = false
    type = "XssMatch"
  }
}
## OWASP Top 10 A1
## Mitigate SQL Injection Attacks
## Matches attempted SQLi patterns in the URI, QUERY_STRING, BODY, COOKIES
## Taken from: https://github.com/aws-samples/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml
resource "aws_waf_sql_injection_match_set" "waf_sqli_match_set" {
  name = "waf_sqli_match_set"

  sql_injection_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    text_transformation = "URL_DECODE"
  }

  sql_injection_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    text_transformation = "HTML_ENTITY_DECODE"
  }

  sql_injection_match_tuples {
    "field_to_match" {
      type = "QUERY_STRING"
    }
    text_transformation = "URL_DECODE"
  }

  sql_injection_match_tuples {
    "field_to_match" {
      type = "QUERY_STRING"
    }
    text_transformation = "HTML_ENTITY_DECODE"
  }

  sql_injection_match_tuples {
    "field_to_match" {
      type = "BODY"
    }
    text_transformation = "URL_DECODE"
  }

  sql_injection_match_tuples {
    "field_to_match" {
      type = "BODY"
    }
    text_transformation = "HTML_ENTITY_DECODE"
  }

  sql_injection_match_tuples {
    "field_to_match" {
      type = "HEADER"
      data = "cookie"
    }
    text_transformation = "URL_DECODE"
  }

  sql_injection_match_tuples {
    "field_to_match" {
      type = "HEADER"
      data = "cookie"
    }
    text_transformation = "HTML_ENTITY_DECODE"
  }
}

resource "aws_waf_rule" "waf_sqli_rule" {
  depends_on = ["aws_waf_sql_injection_match_set.waf_sqli_match_set"]
  name = "SQL Injection Rule"
  metric_name = "WafSqlInjectionRule"
  predicates {
    data_id = "${aws_waf_sql_injection_match_set.waf_sqli_match_set.id}"
    negated = false
    type = "SqlInjectionMatch"
  }
}
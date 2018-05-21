## OWASP Top 10 A4, A5, A9
## Path Traversal, LFI, RFI, Priviliged Paths, Web Roots
## Matches request patterns designed to traverse filesystem paths, and include local or remote files
## Taken from: https://github.com/aws-samples/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml

resource "aws_waf_byte_match_set" "waf_bad_requests_match_set" {
  name = "waf_paths_match_set"

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "CONTAINS"
    target_string = "../"
    text_transformation = "URL_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "CONTAINS"
    target_string = "../"
    text_transformation = "HTML_ENTITY_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "QUERY_STRING"
    }
    positional_constraint = "CONTAINS"
    target_string = "../"
    text_transformation = "URL_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "QUERY_STRING"
    }
    positional_constraint = "CONTAINS"
    target_string = "../"
    text_transformation = "HTML_ENTITY_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "CONTAINS"
    target_string = "://"
    text_transformation = "URL_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "CONTAINS"
    target_string = "://"
    text_transformation = "HTML_ENTITY_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "QUERY_STRING"
    }
    positional_constraint = "CONTAINS"
    target_string = "://"
    text_transformation = "URL_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "QUERY_STRING"
    }
    positional_constraint = "CONTAINS"
    target_string = "://"
    text_transformation = "HTML_ENTITY_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "CONTAINS"
    target_string = "management"
    text_transformation = "URL_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "CONTAINS"
    target_string = "admin"
    text_transformation = "URL_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "STARTS_WITH"
    target_string = "/"
    text_transformation = "URL_DECODE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "ENDS_WITH"
    target_string = ".csg"
    text_transformation = "LOWERCASE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "ENDS_WITH"
    target_string = ".conf"
    text_transformation = "LOWERCASE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "ENDS_WITH"
    target_string = ".config"
    text_transformation = "LOWERCASE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "ENDS_WITH"
    target_string = ".ini"
    text_transformation = "LOWERCASE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "ENDS_WITH"
    target_string = ".log"
    text_transformation = "LOWERCASE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "ENDS_WITH"
    target_string = ".bak"
    text_transformation = "LOWERCASE"
  }

  byte_match_tuples {
    "field_to_match" {
      type = "URI"
    }
    positional_constraint = "ENDS_WITH"
    target_string = ".backup"
    text_transformation = "LOWERCASE"
  }
}

resource "aws_waf_rule" "waf_bad_requests_rule" {
  depends_on = ["aws_waf_byte_match_set.waf_bad_requests_match_set"]
  name = "Bad Requests Rule"
  metric_name = "WafBadRequestsRule"
  predicates {
    data_id = "${aws_waf_rule.waf_bad_requests_rule.id}"
    negated = false
    type = "ByteMatch"
  }
}
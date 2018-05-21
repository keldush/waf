## OWASP Top 10 A9
## Server-side includes & libraries in webroot
## Matches request patterns for webroot objects that shouldn't be directly accessible
## Taken from: https://github.com/aws-samples/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml

resource "aws_waf_byte_match_set" "waf_webroot_match_set" {
  name = "waf_webroot_match_set"

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
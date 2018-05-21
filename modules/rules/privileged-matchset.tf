## OWASP Top 10 A5
## Privileged Access Restrictions
## Restrict access to admin interfaces which can be accessed from behind the WAF
## TODO Move to variables
## Taken from: https://github.com/aws-samples/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml

resource "aws_waf_byte_match_set" "waf_privileged_match_set" {
  name = "waf_privileged_match_set"

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
}
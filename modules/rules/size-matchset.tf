## Mitigate abnormal requests via size restrictions
## Enforce consistent request hygiene, limit size of key elements
## TODO Determine these numbers and move to variables
## Taken from: https://github.com/aws-samples/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml

resource "aws_waf_size_constraint_set" "waf_size_match_set" {
  name = "waf_size_match_set"

  size_constraints {
    comparison_operator = "GT"
    "field_to_match" {
      type = "URI"
    }
    size = 512
    text_transformation = "NONE"
  }

  size_constraints {
    comparison_operator = "GT"
    "field_to_match" {
      type = "QUERY_STRING"
    }
    size = 1024
    text_transformation = "NONE"
  }

  size_constraints {
    comparison_operator = "GT"
    "field_to_match" {
      type = "BODY"
    }
    size = 1024
    text_transformation = "NONE"
  }

  size_constraints {
    comparison_operator = "GT"
    "field_to_match" {
      type = "HEADER"
      data = "cookie"
    }
    size = 4093
    text_transformation = "NONE"
  }



}
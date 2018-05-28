#The current AWS caller identity so it can be referred to later
data "aws_caller_identity" "current" { }

#The first IP set which the bad reputation list parser lambda will update
resource "aws_waf_ipset" "waf_auto_block_set" {
  name = "Bad Reputation Auto Block Set"

  lifecycle {
    ignore_changes = ["ip_set_descriptors"]
  }
}

#The first WAF rule for the IP set blocking
resource "aws_waf_rule" "waf_auto_block_rule" {
  depends_on = ["aws_waf_ipset.waf_auto_block_set"]
  name = "Bad Reputation Auto Block Rule"
  metric_name = "WafBadReputationAutoBlockRule"
  predicates {
    data_id = "${aws_waf_ipset.waf_auto_block_set.id}"
    negated = false
    type = "IPMatch"
  }
}

#The second IP set which the bad reputation list parser lambda will update
resource "aws_waf_ipset" "waf_auto_block_set2" {
  name = "Bad Reputation Auto Block Set 2"

  lifecycle {
    ignore_changes = ["ip_set_descriptors"]
  }
}

#The second WAF rule for the IP set blocking
resource "aws_waf_rule" "waf_auto_block_rule2" {
  depends_on = ["aws_waf_ipset.waf_auto_block_set2"]
  name = "Bad Reputation Auto Block Rule 2"
  metric_name = "WafBadReputationAutoBlockRule2"
  predicates {
    data_id = "${aws_waf_ipset.waf_auto_block_set2.id}"
    negated = false
    type = "IPMatch"
  }
}

#An S3 bucket to store the bad reputation list parser code
resource "aws_s3_bucket" "waf_bad_reputation_protection_bucket" {
  count = "${var.enable_module}"
  bucket = "waf-bad-reputation-protection"
  acl = "private"

  tags {
    Name = "WAF Bad Reputation Protection Files"
  }
}

#Place the bad reputation list parser code in to the S3 bucket
resource "aws_s3_bucket_object" "bad_reputation_list_parser_zip" {
  count = "${var.enable_module}"
  depends_on = ["aws_s3_bucket.waf_bad_reputation_protection_bucket"]
  bucket = "waf-bad-reputation-protection"
  key = "reputation-lists-parser.zip"
  source = "${path.module}/reputation-lists-parser.zip"
  etag = "${md5(file("${path.module}/reputation-lists-parser.zip"))}"
}

#A lambda function to execute the bad reputation list parser code
resource "aws_lambda_function" "bad_reputation_list_parser_function" {
  count = "${var.enable_module}"
  depends_on = ["aws_s3_bucket_object.bad_reputation_list_parser_zip"]
  function_name = "BadReputationListParserFunction-${element(split("-",uuid()),0)}"
  description = "This lambda function checks third-party IP reputation lists hourly for new IP ranges to block. These lists include the Spamhaus Dont Route Or Peer (DROP) and Extended Drop (EDROP) lists, the Proofpoint Emerging Threats IP list, and the Tor exit node list."
  role = "${aws_iam_role.bad_reputation_list_parser_iam_role.arn}"
  handler = "reputation-lists-parser.handler"
  s3_bucket = "${aws_s3_bucket.waf_bad_reputation_protection_bucket.bucket}"
  s3_key = "reputation-lists-parser.zip"
  runtime = "nodejs4.3"
  memory_size = "128"
  timeout = "300"
  environment {
    variables = {
      SendAnonymousUsageData = "${var.send_anonymous_usage}"
      UUID = "${uuid()}"
    }
  }
}

#An hourly CloudWatch event rule
resource "aws_cloudwatch_event_rule" "bad_reputation_list_parser_function_events_rule" {
  count = "${var.enable_module}"
  depends_on = ["aws_lambda_function.bad_reputation_list_parser_function", "aws_waf_ipset.waf_auto_block_set", "aws_waf_ipset.waf_auto_block_set2"]
  name = "BadReputationListsParserFunctionEventsRule-${element(split("-",uuid()),0)}"
  description = "WAF Bad Reputation Lists"
  schedule_expression = "rate(1 hour)"
}

#A CloudWatch event target to pass the array of bad reputation URLs to the bad reputation list parser function. Triggered by the above rule
resource "aws_cloudwatch_event_target" "bad_reputation_list_parser_cloudwatch_event_target" {
  count = "${var.enable_module}"
  depends_on = ["aws_cloudwatch_event_rule.bad_reputation_list_parser_function_events_rule"]
  rule = "${aws_cloudwatch_event_rule.bad_reputation_list_parser_function_events_rule.name}"
  target_id = "${aws_lambda_function.bad_reputation_list_parser_function.id}"
  arn = "${aws_lambda_function.bad_reputation_list_parser_function.arn}"
  input = "{\"lists\":[{\"url\":\"https://www.spamhaus.org/drop/drop.txt\"},{\"url\":\"https://check.torproject.org/exit-addresses\",\"prefix\":\"ExitAddress \"},{\"url\":\"https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt\"}],\"ipSetIds\": [\"${aws_waf_ipset.waf_auto_block_set.id}\",\"${aws_waf_ipset.waf_auto_block_set2.id}\"]}"
}

#Permission for the CloudWatch event to call the bad reputation list parser function
resource "aws_lambda_permission" "bad_reputation_list_parser_function_permission" {
  count = "${var.enable_module}"
  depends_on = ["aws_lambda_function.bad_reputation_list_parser_function", "aws_cloudwatch_event_rule.bad_reputation_list_parser_function_events_rule"]
  function_name = "${aws_lambda_function.bad_reputation_list_parser_function.arn}"
  action = "lambda:InvokeFunction"
  principal = "events.amazonaws.com"
  statement_id = "AllowExecutionFromCloudWatch"
  source_arn = "${aws_cloudwatch_event_rule.bad_reputation_list_parser_function_events_rule.arn}"
}
#The current AWS caller identity and region so they can be referred to later
data "aws_caller_identity" "current" { }
data "aws_region" "current" { }

#The IP set which the bad bot handler lambda will update
resource "aws_waf_ipset" "waf_auto_block_set" {
  name = "Bad Bot Protection Auto Block Set"
}

#The WAF rule for the IP set blocking
resource "aws_waf_rule" "waf_auto_block_rule" {
  depends_on = ["aws_waf_ipset.waf_auto_block_set"]
  name = "Bad Bot Protection Auto Block Rule"
  metric_name = "WafBadBotProtectionAutoBlockRule"
  predicates {
    data_id = "${aws_waf_ipset.waf_auto_block_set.id}"
    negated = false
    type = "IPMatch"
  }
}

#An S3 bucket to store the bad bot handler code
resource "aws_s3_bucket" "waf_bad_bot_protection_bucket" {
  count = "${var.enable_module}"
  bucket = "waf-bad-protection"
  acl = "private"

  tags {
    Name = "WAF Bad Bot Protection Files"
  }
}

#Place the bad bot handler code in to the S3 bucket
resource "aws_s3_bucket_object" "bad_bot_handler_zip" {
  count = "${var.enable_module}"
  depends_on = ["aws_s3_bucket.waf_bad_bot_protection_bucket"]
  bucket = "${aws_s3_bucket.waf_bad_bot_protection_bucket.bucket}"
  key = "bad-bot-handler.zip"
  source = "${path.module}/bad-bot-handler.zip"
  etag = "${md5(file("${path.module}/bad-bot-handler.zip"))}"
}

#A lambda function to execute the bad bot handler code
resource "aws_lambda_function" "bad_bot_handler_function" {
  count = "${var.enable_module}"
  depends_on = ["aws_s3_bucket_object.bad_bot_handler_zip"]
  function_name = "BadBotHandlerFunction-${element(split("-",uuid()),0)}"
  description = "This lambda function will intercept and inspect trap endpoint requests to extract its IP address, and then add it to an AWS WAF block list."
  role = "${aws_iam_role.bad_bot_handler_iam_role.arn}"
  handler = "bad-bot-handler.lambda_handler"
  s3_bucket = "${aws_s3_bucket.waf_bad_bot_protection_bucket.bucket}"
  s3_key = "bad-bot-handler.zip"
  runtime = "python2.7"
  memory_size = "128"
  timeout = "300"
  environment {
    variables = {
      IP_SET_ID_BAD_BOT = "${aws_waf_ipset.waf_auto_block_set.id}"
      LOG_TYPE = "cloudfront"
      REGION = "${data.aws_region.current.name}"
      SEND_ANONYMOUS_USAGE_DATA = "${var.send_anonymous_usage}"
      UUID = "${uuid()}"
    }
  }
}
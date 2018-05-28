#The current AWS caller identity so it can be referred to later
data "aws_caller_identity" "current" { }

#The IP set which the log parser lambda will update
resource "aws_waf_ipset" "waf_auto_block_set" {
  name = "Probe Protection Auto Block Set"
}

#The WAF rule for the IP set blocking
resource "aws_waf_rule" "waf_auto_block_rule" {
  depends_on = ["aws_waf_ipset.waf_auto_block_set"]
  name = "Probe Protection Auto Block Rule"
  metric_name = "WafProbeProtectionAutoBlockRule"
  predicates {
    data_id = "${aws_waf_ipset.waf_auto_block_set.id}"
    negated = false
    type = "IPMatch"
  }
}

#An S3 bucket to store the log parser code
resource "aws_s3_bucket" "waf_probe_protection_bucket" {
  count = "${var.enable_module}"
  bucket = "waf-probe-protection"
  acl = "private"

  tags {
    Name = "WAF Probe Protection Files"
  }
}

#Place the log parser code in to the S3 bucket
resource "aws_s3_bucket_object" "log_parser_zip" {
  count = "${var.enable_module}"
  depends_on = ["aws_s3_bucket.waf_probe_protection_bucket"]
  bucket = "${aws_s3_bucket.waf_probe_protection_bucket.bucket}"
  key = "log-parser.zip"
  source = "${path.module}/log-parser.zip"
  etag = "${md5(file("${path.module}/log-parser.zip"))}"
}

#A lambda function to execute the log parser code
resource "aws_lambda_function" "log_parser_function" {
  count = "${var.enable_module}"
  depends_on = ["aws_s3_bucket_object.log_parser_zip"]
  function_name = "LogParserFunction-${element(split("-",uuid()),0)}"
  description = "Parse CloudFront access logs to identify suspicious behavior and block those IP addresses for a defined period of time."
  role = "${aws_iam_role.log_parser_iam_role.arn}"
  handler = "log-parser.lambda_handler"
  s3_bucket = "${aws_s3_bucket.waf_probe_protection_bucket.bucket}"
  s3_key = "log-parser.zip"
  runtime = "python2.7"
  memory_size = "512"
  timeout = "300"

  #Terraform variables to pass the lambda environment
  environment {
    variables = {
      OUTPUT_BUCKET = "${var.access_log_bucket}"
      IP_SET_ID_BLACKLIST = "${var.manual_blacklist_ip_set}"
      LIMIT_IP_ADDRESS_RANGES_PER_IP_MATCH_CONDITION = "10000"
      IP_SET_ID_AUTO_BLOCK = "${aws_waf_ipset.waf_auto_block_set.id}"
      ERROR_PER_MINUTE_LIMIT = "${var.error_threshold}"
      BLACKLIST_BLOCK_PERIOD = "${var.block_period}"
      SEND_ANONYMOUS_USAGE_DATA = "${var.send_anonymous_usage}"
      MAX_AGE_TO_UPDATE = "30"
      LOG_TYPE = "cloudfront"
      UUID = "${uuid()}"
    }
  }
}

#Permission for S3 to call the log parser function
resource "aws_lambda_permission" "log_parser_function_permission" {
  count = "${var.enable_module}"
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:*"
  function_name = "${aws_lambda_function.log_parser_function.arn}"
  principal = "s3.amazonaws.com"
  source_account = "${data.aws_caller_identity.current.account_id}"
}

#An S3 notification to trigger the log parser function when log objects are created
resource "aws_s3_bucket_notification" "log_parser_function_s3_notification" {
  count = "${var.enable_module}"
  depends_on = ["aws_lambda_function.log_parser_function"]
  bucket = "${var.access_log_bucket}"
  lambda_function = [
    {
      id = "LogParserFunction"
      lambda_function_arn = "${aws_lambda_function.log_parser_function.arn}"
      events = ["s3:ObjectCreated:*"]
      filter_suffix = "gz"
    }
  ]
}


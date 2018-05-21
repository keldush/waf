#The current AWS caller identity and region so they can be referred to later
data "aws_caller_identity" "current" { }
data "aws_region" "current" {}


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
      REGION = "${data.aws_region.current}"
      SEND_ANONYMOUS_USAGE_DATA = "${var.send_anonymous_usage}"
      UUID = "${uuid()}"
    }
  }
}

#A lambda permission for the bad bot handler lambda function
resource "aws_lambda_permission" "bad_bot_handler_function_permission" {
  count = "${var.enable_module}"
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:*"
  function_name = "${aws_lambda_function.bad_bot_handler_function.arn}"
  principal = "apigateway.amazonaws.com"
}

#An API gateway to lure in the bad bots
resource "aws_api_gateway_rest_api" "bad_bot_api_gateway" {
  count = "${var.enable_module}"
  name = "Bad Bot API Gateway"
  description = "API Gateway to lure bad bots"
}

#A resource for the API gateway
resource "aws_api_gateway_resource" "bad_bot_api_gateway_resource" {
  count = "${var.enable_module}"
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  parent_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.root_resource_id}"
  path_part = "waf"
}

#A GET method for the API gateway
resource "aws_api_gateway_method" "bad_bot_api_gateway_method" {
  count = "${var.enable_module}"
  depends_on = ["aws_lambda_function.bad_bot_handler_function", "aws_lambda_permission.bad_bot_handler_function_permission", "aws_api_gateway_rest_api.bad_bot_api_gateway"]
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.bad_bot_api_gateway_resource.id}"
  http_method = "GET"
  authorization = "NONE"
  request_parameters = { "method.request.header.X-Forwarded-For" = false }
}

#The 200 OK response for the API gateway method
resource "aws_api_gateway_method_response" "bad_bot_api_gateway_method_response_OK" {
  count = "${var.enable_module}"
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.bad_bot_api_gateway_resource.id}"
  http_method = "${aws_api_gateway_method.bad_bot_api_gateway_method.http_method}"
  status_code = "200"
}

#An API gateway inegration to POST to the lambda
resource "aws_api_gateway_integration" "bad_bot_api_gateway_integration" {
  count = "${var.enable_module}"
  depends_on = ["aws_api_gateway_method.bad_bot_api_gateway_method"]
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.bad_bot_api_gateway_resource.id}"
  http_method = "${aws_api_gateway_method.bad_bot_api_gateway_method.http_method}"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${data.aws_region.current}:lambda:path/2015-03-31/functions/${aws_lambda_function.bad_bot_handler_function.arn}/invocations"
  type = "AWS"
  request_templates = {
    "application/json" = "{\n    \"source_ip\" : \"$input.params('X-Forwarded-For')\",\n    \"user_agent\" : \"$input.params('User-Agent')\",\n    \"bad_bot_ip_set\" : \"${aws_waf_ipset.waf_auto_block_set.id}\"\n}"
  }
}

#API gateway integration response
resource "aws_api_gateway_integration_response" "bad_bot_api_gateway_integration_response" {
  count = "${var.enable_module}"
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.bad_bot_api_gateway_resource.id}"
  http_method = "${aws_api_gateway_integration.bad_bot_api_gateway_integration.http_method}"
  status_code = "${aws_api_gateway_method_response.bad_bot_api_gateway_method_response_OK.status_code}"
  response_templates = { "application/json" = "" }
}

resource "aws_api_gateway_deployment" "bad_bot_api_gateway_deployment_stage" {
  count = "${var.enable_module}"
  depends_on = ["aws_api_gateway_method.bad_bot_api_gateway_method"]
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  stage_name = "DeploymentStage"
  description = "Deployment Stage"
}

resource "aws_api_gateway_deployment" "bad_bot_api_gateway_prod_stage" {
  count = "${var.enable_module}"
  depends_on = ["aws_api_gateway_deployment.bad_bot_api_gateway_deployment"]
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  stage_name = "ProdStage"
  description = "Production Stage"
}
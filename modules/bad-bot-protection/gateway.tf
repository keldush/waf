#An API gateway - "rest api" is old terminology
resource "aws_api_gateway_rest_api" "bad_bot_api_gateway" {
  name = "Bad Bot API Gateway"
  description = "A honeypot to lure bad bots"
}

#A resource for the API gateway using the special {+proxy} path to match all paths
resource "aws_api_gateway_resource" "bad_bot_api_gateway_proxy_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  parent_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.root_resource_id}"
  path_part = "{proxy+}"
}

#An API gateway method to match all request types
resource "aws_api_gateway_method" "bad_bot_api_gateway_proxy_method" {
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.bad_bot_api_gateway_proxy_resource.id}"
  http_method = "ANY"
  authorization = "NONE"
}

#An API gateway integrateion to POST the incoming request on to the bad bot handler function
resource "aws_api_gateway_integration" "bad_api_gateway_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  resource_id = "${aws_api_gateway_method.bad_bot_api_gateway_proxy_method.resource_id}"
  http_method = "${aws_api_gateway_method.bad_bot_api_gateway_proxy_method.http_method}"

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.bad_bot_handler_function.invoke_arn}"
}

#An API gateway method to match all request types, but at the root of the API gateway, unmatched by the previous method
resource "aws_api_gateway_method" "bad_bot_api_gateway_proxy_root_method" {
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  resource_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.root_resource_id}"
  http_method = "ANY"
  authorization = "NONE"
}

#An API gateway integrateion to POST the incoming request on to the bad bot handler function, but at the root of the API gateway
resource "aws_api_gateway_integration" "bad_api_gateway_root_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  resource_id = "${aws_api_gateway_method.bad_bot_api_gateway_proxy_root_method.resource_id}"
  http_method = "${aws_api_gateway_method.bad_bot_api_gateway_proxy_root_method.http_method}"

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.bad_bot_handler_function.invoke_arn}"
}

#Deploy the API gateway
resource "aws_api_gateway_deployment" "bad_bot_api_gateway_deployment" {
  depends_on = [
    "aws_api_gateway_integration.bad_api_gateway_integration",
    "aws_api_gateway_integration.bad_api_gateway_root_integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.bad_bot_api_gateway.id}"
  stage_name = "test"
}

#Allow the API gateway to call the lambda
resource "aws_lambda_permission" "bad_bot_api_gateway_function_permission" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.bad_bot_handler_function.arn}"
  principal = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.bad_bot_api_gateway_deployment.execution_arn}/*/*"
}
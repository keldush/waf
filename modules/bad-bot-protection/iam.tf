#IAM role for the bad bot handler lambda
resource "aws_iam_role" "bad_bot_handler_iam_role" {
  count = "${var.enable_module}"
  name = "bad_bot_handler_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  path = "/"
}

#IAM role policy to allow the bad bot handler to access the WAF's change token
resource "aws_iam_role_policy" "bad_bot_handler_get_change_token_iam_policy" {
  count = "${var.enable_module}"
  name = "bad_bot_handler_get_change_token_iam_policy"
  role = "${aws_iam_role.bad_bot_handler_iam_role.id}"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "waf:GetChangeToken"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

#IAM role policy to allow the bad bot handler to get and put the WAF IP sets
resource "aws_iam_role_policy" "bad_bot_handler_waf_get_update_ip_set_iam_policy" {
  count = "${var.enable_module}"
  name = "bad_bot_handler_waf_get_update_ip_set_iam_policy"
  role = "${aws_iam_role.bad_bot_handler_iam_role.id}"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "waf:GetIPSet",
        "waf:UpdateIPSet"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:waf::${data.aws_caller_identity.current.account_id}:ipset/${aws_waf_ipset.waf_auto_block_set.id}"
      ]
    }
  ]
}
EOF
}

#IAM role policy to allow the bad bot handler to the logs
resource "aws_iam_role_policy" "bbad_bot_handler_log_access_iam_policy" {
  count = "${var.enable_module}"
  name = "bad_bot_handler_log_access_iam_policy"
  role = "${aws_iam_role.bad_bot_handler_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}

#IAM role policy to allow the bad bot handler to read CloudWatch metric statistics
resource "aws_iam_role_policy" "bad_bot_handler_cloudwatch_access_iam_policy" {
  count = "${var.enable_module}"
  name = "bad_bot_handler_cloudwatch_access_iam_policy"
  role = "${aws_iam_role.bad_bot_handler_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:GetMetricStatistics"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

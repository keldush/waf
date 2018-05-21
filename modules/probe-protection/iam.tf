#IAM role for the log parser lambda
resource "aws_iam_role" "log_parser_iam_role" {
  count = "${var.enable_module}"
  name = "log_parser_iam_role"
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

#IAM role policy to allow the log parser access to the S3 bucket
resource "aws_iam_role_policy" "log_parser_s3_get_iam_policy" {
  count = "${var.enable_module}"
  name = "log_parser_s3_get_iam_policy"
  role = "${aws_iam_role.log_parser_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.access_log_bucket}/*"
      ]
    }
  ]
}
EOF
}

#IAM role policy to allow the log parser to put the blocked IPs in to the S3 bucket
resource "aws_iam_role_policy" "log_parser_s3_put_iam_policy" {
  count = "${var.enable_module}"
  name = "log_parser_s3_put_iam_policy"
  role = "${aws_iam_role.log_parser_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.access_log_bucket}/aws-waf-security-automations-current-blocked-ips.json"
      ]
    }
  ]
}
EOF
}

#IAM role policy to allow the log parser to access the WAF's change token
resource "aws_iam_role_policy" "log_parser_get_change_token_iam_policy" {
  count = "${var.enable_module}"
  name = "log_parser_get_change_token_iam_policy"
  role = "${aws_iam_role.log_parser_iam_role.id}"
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

#IAM role policy to allow the log parser to get and put the WAF IP sets
resource "aws_iam_role_policy" "log_parser_waf_get_update_ip_set_iam_policy" {
  count = "${var.enable_module}"
  name = "log_parser_waf_get_update_ip_set_iam_policy"
  role = "${aws_iam_role.log_parser_iam_role.id}"
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
          "arn:aws:waf::${data.aws_caller_identity.current.account_id}:ipset/${var.manual_blacklist_ip_set}",
          "arn:aws:waf::${data.aws_caller_identity.current.account_id}:ipset/${aws_waf_ipset.waf_auto_block_set.id}"
      ]
    }
  ]
}
EOF
}

#IAM role policy to allow the log parser access to the logs
resource "aws_iam_role_policy" "log_parser_log_access_iam_policy" {
  count = "${var.enable_module}"
  name = "log_parser_log_access_iam_policy"
  role = "${aws_iam_role.log_parser_iam_role.id}"
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

#IAM role policy to allow the log parser to read CloudWatch metric statistics
resource "aws_iam_role_policy" "log_parser_cloudwatch_access_iam_policy" {
  count = "${var.enable_module}"
  name = "log_parser_cloudwatch_access_iam_policy"
  role = "${aws_iam_role.log_parser_iam_role.id}"
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
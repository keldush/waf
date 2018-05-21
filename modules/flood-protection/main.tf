#The IP set to contains IPs trying to flood
resource "aws_waf_ipset" "flood_protection_set" {
  name = "Flood Protection Set"
}

#The WAF rule for the IP set blocking
resource "aws_waf_rate_based_rule" "waf_flood_protection_rule" {
  depends_on = ["aws_waf_ipset.flood_protection_set"]
  name = "Flood Protection Rule"
  metric_name = "WafFloodProtectionRule"

  rate_key = "IP"
  rate_limit = "${var.rate_limit}"
}
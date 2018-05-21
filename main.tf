module "probe_protection" {
  source = "./modules/probe-protection"
  enable_module = true
  block_period = "5"
  manual_blacklist_ip_set = "${var.manual_blacklist_ip_set}"
  access_log_bucket = "${var.cloudfront_access_log_bucket}"
}

module "bad_reputation_protection" {
  source = "./modules/bad-reputation-protection"
  enable_module = true
}

module "bad_bot_protection" {
  source = "./modules/bad-bot-protection"
  enable_module = true
}

module "flood_protection" {
  source = "./modules/flood-protection"
}

module "sqli_protection" {
  source = "./modules/sqli-protection"
}

module "xss_protection" {
  source = "./modules/xss-protection"
}

module "bad_request_protection" {
  source = "./modules/bad-request-protection"
}

#An empty whitelist WAF rule if one isn't set
resource "aws_waf_rule" "waf_empty_whitelist" {
  count = "${var.manual_whitelist_rule_id == "" ? 1 : 0}"
  metric_name = "WafEmptyWhitelist"
  name = "Empty Whitelist Rule"
}

#An empty blacklist WAF rule if one isn't set
resource "aws_waf_rule" "waf_empty_blacklist" {
  count = "${var.manual_blacklist_rule_id == "" ? 1 : 0}"
  metric_name = "WafEmptyBlacklist"
  name = "Empty Blacklist Rule"
}

resource "aws_waf_web_acl" "waf_web_acl" {
  depends_on = ["module.probe_protection", "module.bad_reputation_protection", "module.flood_protection", "aws_waf_rule.waf_empty_blacklist", "aws_waf_rule.waf_empty_whitelist"]
  name = "${var.waf_acl_name}"
  metric_name = "MaliciousRequesters"

  default_action {
    type = "${var.default_waf_action}"
  }

  rules {
    "action" {
      type = "BLOCK"
    }
    priority = 0
    rule_id = "${var.manual_blacklist_rule_id != "" ? var.manual_blacklist_rule_id : aws_waf_rule.waf_empty_blacklist.id}"
  }

  rules {
    "action" {
      type = "BLOCK"
    }
    priority = 10
    rule_id = "${module.bad_reputation_protection.bad_reputation_waf_rule_id}"
  }

  rules {
    "action" {
      type = "BLOCK"
    }
    priority = 20
    rule_id = "${module.bad_reputation_protection.bad_reputation_waf_rule2_id}"
  }

  rules {
    action {
      type = "BLOCK"
    }
    priority = 30
    rule_id = "${module.probe_protection.probe_protection_waf_rule_id}"
  }

  rules {
    "action" {
      type = "BLOCK"
    }
    priority = 40
    rule_id = "${module.flood_protection.flood_protection_waf_rule_id}"
    type = "RATE_BASED"
  }

  rules {
    "action" {
      type = "BLOCK"
    }
    priority = 50
    rule_id = "${module.sqli_protection.sqli_protection_waf_rule_id}"
  }

  rules {
    "action" {
      type = "BLOCK"
    }
    priority = 60
    rule_id = "${module.xss_protection.xss_protection_waf_rule_id}"
  }

  rules {
    "action" {
      type = "BLOCK"
    }
    priority = 70
    rule_id = "${module.bad_bot_protection.bad_bot_protection_waf_rule_id}"
  }

  rules {
    action {
      type = "ALLOW"
    }
    priority = 90
    rule_id = "${var.manual_whitelist_rule_id != "" ? var.manual_whitelist_rule_id : aws_waf_rule.waf_empty_whitelist.id}"
  }
}

variable "waf_acl_name" {
  default = "default-waf-acl"
  description = "The name of the WAF Access Control List"
}

variable "default_waf_action" {
  description = "The default behaviour of the WAF. Value must be either BLOCK or ALLOW"
  default = "BLOCK"
}

variable "cloudfront_access_log_bucket" {
  description = "The S3 bucket where CloudFront logs are stored"
}

variable "manual_blacklist_ip_set" {
  description = "The IP set of an existing static blacklist of IPs"
  default = ""
}

variable "manual_blacklist_rule_id" {
  description = "The ID of an existing static blacklist of IPs"
  default = ""
}

variable "manual_whitelist_rule_id" {
  description = "The ID of an existing static whitelist of IPs"
  default = ""
}
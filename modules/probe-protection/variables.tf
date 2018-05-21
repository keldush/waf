variable "enable_module" {
  description = "Whether to enable the module or not"
  default = false
}

variable "access_log_bucket" {
  description = "The S3 location of the CloudFront logs to parse"
  default = "This is required but if there is no default, Terraform will complain when enable_module is false."
}

variable "manual_blacklist_ip_set" {
  description = "The IP set of an existing static blacklist"
  default = ""
}

variable "block_period" {
  default = "600"
  description = "The number of minutes to block a malicious IP address"
}

variable "error_threshold" {
  default = "50"
  description = "The threshold for the number of errors per minute"
}

variable "send_anonymous_usage" {
  default = "no"
  description = "Whether to send anonymous usage statistics to AWS"
}
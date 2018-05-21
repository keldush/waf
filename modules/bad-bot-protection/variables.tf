variable "enable_module" {
  description = "Whether to enable the module or not"
  default = false
}

variable "send_anonymous_usage" {
  default = "no"
  description = "Whether to send anonymous usage statistics to AWS"
}
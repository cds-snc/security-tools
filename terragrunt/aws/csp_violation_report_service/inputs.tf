variable "log_analytics_workspace_id" {
  description = "The Sentinel workspace ID. Used by the Sentinel Forwarder to send the CSP reports to Sentinel."
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace_key" {
  description = "The Sentinel workspace authentication key. Used by the Sentinel Forwarder to send the CSP reports to Sentinel."
  type        = string
  sensitive   = true
}

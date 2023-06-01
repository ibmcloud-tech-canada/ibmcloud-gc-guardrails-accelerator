variable "ibmcloud_api_key" {
  description = "API Key with authorization to create the resources in this script"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Region where all regional services will be deployed"
  type        = string
  default     = "ca-tor"
}

# Use "TOTP" to configure TOTP for all non-federated users.  Other allowed values can be found
# here: https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_account_settings
variable "mfa" {
  description = "MFA configuration to use.  Defaults to email for all users."
  type        = string
  default     = "LEVEL1"
}

variable "resource_group_name" {
  description = "Name of resource group into which you will provision Activity Tracker and other account services."
  type        = string
  default     = "base-resource-group"
}

variable "prefix" {
  description = "Prefix to use in naming convention for account services"
  type        = string
  default     = "base"
}

variable "allowed_ips" {
  description = "Comma-delimited list of IPs and/or IP ranges that allowed access to the account"
  type        = string
  default     = "0.0.0.0/0"
}

variable "restrict_serviceids" {
  description = "If restricted, users will need explicit IAM permissions to create service ids.  Allowed values are RESTRICTED, NOT_RESTRICTED, NOT_SET"
  type        = string
  default     = "RESTRICTED"
}

variable "restrict_apikeys" {
  description = "If restricted, users will need explicit IAM permissions to create API Keys.  Allowed values are RESTRICTED, NOT_RESTRICTED, NOT_SET"
  type        = string
  default     = "RESTRICTED"
}

variable "activity_tracker_plan" {
  description = "Plan for Activity tracker, 7-day or 30-day"
  type        = string
  default     = "7-day"
}


# The default will forward local events from all regions that support event routing.  
# It will also forward global events like IAM events and COS bucket creation events
variable "activity_tracker_route_sources" {
  description = "List of regions for which you want to forward local events.  Include global for global events"
  type        = list(string)
  default     = ["us-south", "us-east", "global"]
}



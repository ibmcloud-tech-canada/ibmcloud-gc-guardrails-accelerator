## Configure account settings
resource "ibm_iam_account_settings" "iam_account_settings_instance" {
  mfa                             = var.mfa
  restrict_create_service_id      = var.restrict_serviceids
  restrict_create_platform_apikey = var.restrict_apikeys
  allowed_ip_addresses            = var.allowed_ips
}

# Disable the public access group
resource "ibm_iam_access_group_account_settings" "iam_access_group_account_settings" {
  public_access_enabled = false
}

# Create resource group where Activity Tracker and other operational services will be deployed
resource "ibm_resource_group" "group" {
  name = var.resource_group_name
}

# Create an instance of Key Protect
resource "ibm_resource_instance" "key_protect_instance" {
  name              = "${var.prefix}-kms"
  resource_group_id = ibm_resource_group.group.id
  service           = "kms"
  plan              = "tiered-pricing"
  location          = var.region
}

# Create an instance of Cloud Object Storage
resource "ibm_resource_instance" "cos" {
  name              = "${var.prefix}-cos"
  resource_group_id = ibm_resource_group.group.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}

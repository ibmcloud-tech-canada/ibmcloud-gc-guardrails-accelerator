# Get the resource group for this tenant
data "ibm_resource_group" "group" {
  name = local.resource_group_name
}

# Create a VPC
resource "ibm_is_vpc" "vpc" {
  name                        = "${local.prefix}-vpc"
  resource_group              = data.ibm_resource_group.group.id
  address_prefix_management   = "manual"
  default_security_group_name = "${local.prefix}-sg-default"
  default_network_acl_name    = "${local.prefix}-acl-default"
  default_routing_table_name  = "${local.prefix}-rt-default"
}

# Address prefixes for the workload vpc
resource "ibm_is_vpc_address_prefix" "vpc_address_prefixes" {
  count = 3

  name       = "${local.prefix}-${format("%02s", count.index + 1)}"
  zone       = local.vpc_zone_names[count.index]
  vpc        = ibm_is_vpc.vpc.id
  cidr       = var.vpc_cidrs[count.index]
  is_default = true
}

# Look up details of the cos.  
data "ibm_resource_instance" "cos" {
  name              = local.cos_name
  resource_group_id = data.ibm_resource_group.group.id
}

# Look up details of the key management service.  
# This could be either Key Protect or HPCS.
data "ibm_resource_instance" "kms" {
  name              = local.kms_name
  resource_group_id = data.ibm_resource_group.group.id
}


## Create a key for flowlogs cos bucket
resource "ibm_kms_key" "flowlogs_key" {
  instance_id  = data.ibm_resource_instance.kms.guid
  key_name     = "${local.prefix}-flowlogs-key"
  standard_key = false
  force_delete = true
}

# Use a random suffix to avoid collisions with other buckets
resource "random_string" "cos_random_suffix" {
  length           = 4
  special          = true
  override_special = ""
  min_lower        = 4
}

## Create a bucket for flowlogs
resource "ibm_cos_bucket" "flowlogs_bucket" {

  bucket_name          = "${local.prefix}-flowlogs-${random_string.cos_random_suffix.result}"
  resource_instance_id = data.ibm_resource_instance.cos.id
  region_location      = local.region
  storage_class        = "smart"
  key_protect          = ibm_kms_key.flowlogs_key.crn
  force_delete         = true

  expire_rule {
    days   = 7
    enable = true
  }
}

# Authorize infrastructure to write flow logs to COS.  We only need to set this up
# once to allow the Flow Log Collector to write to the COS instance
# for this environment.
resource "ibm_iam_authorization_policy" "vpc_auth_flow_policy" {
  source_service_name         = "is"
  source_resource_type        = "flow-log-collector"
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = data.ibm_resource_instance.cos.guid
  roles                       = ["Writer"]
}

# Flow log for the VPC
resource "ibm_is_flow_log" "instance_flowlog" {
  depends_on = [
    ibm_cos_bucket.flowlogs_bucket,
    ibm_iam_authorization_policy.vpc_auth_flow_policy
  ]

  name = join("-", ["${local.prefix}",
    "fl",
  ibm_is_vpc.vpc.name])
  resource_group = data.ibm_resource_group.group.id
  target         = ibm_is_vpc.vpc.id
  active         = true
  storage_bucket = ibm_cos_bucket.flowlogs_bucket.bucket_name
}

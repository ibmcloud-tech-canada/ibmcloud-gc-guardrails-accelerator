data "ibm_resource_group" "group" {
  name = local.resource_group_name
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

## Create a key for SCC cos bucket
resource "ibm_kms_key" "scc_reports_key" {
  instance_id  = data.ibm_resource_instance.kms.guid
  key_name     = "${local.prefix}-scc-reports-key"
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

# Authorize COS to read from Key Protect
resource "ibm_iam_authorization_policy" "cos_kp_policy" {
  source_service_name = "cloud-object-storage"
  target_service_name = "kms"
  roles               = ["Reader"]
}

## Create a bucket for SCC reports
resource "ibm_cos_bucket" "scc_reports" {
  depends_on = [
    ibm_iam_authorization_policy.cos_kp_policy
  ]
  bucket_name          = "${local.prefix}-scc-reports-${random_string.cos_random_suffix.result}"
  resource_instance_id = data.ibm_resource_instance.cos.id
  region_location      = local.region
  storage_class        = "smart"
  key_protect          = ibm_kms_key.scc_reports_key.crn
  force_delete         = true

  expire_rule {
    days   = 7
    enable = true
  }
}

## Authorize SCC to write to your COS instance for SCC reports
## Cannot refine this to a specific bucket as the lookup in SCC won't work
resource "ibm_iam_authorization_policy" "scc_cos_policy" {
  source_service_name         = "compliance"
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = data.ibm_resource_instance.cos.guid
  roles                       = ["Writer"]
}

# Create Activity Tracker instance in Toronto and route global events and events from
# us-south and us-east to this instance.

#############################################################################
# Activity Tracker and Route
#############################################################################
## Create Activity Tracker instance in Toronto
resource "ibm_resource_instance" "logdnaat_instance" {
  name              = "activity-tracker-ca-tor"
  service           = "logdnaat"
  plan              = var.activity_tracker_plan
  location          = var.region
  resource_group_id = ibm_resource_group.group.id
}


## Configure atracker settings.  Metadata storage not available in Toronto.
resource "ibm_atracker_settings" "atracker_settings" {
  metadata_region_primary   = "us-east"
  metadata_region_backup    = "us-south"
  private_api_endpoint_only = false
  # Optional but recommended lifecycle flag to ensure target delete order is correct
  lifecycle {
    create_before_destroy = true
  }
}

## Make your activity tracker instance in Toronto the target
resource "ibm_atracker_target" "atracker_logdna_target" {
  depends_on = [
    ibm_atracker_settings.atracker_settings
  ]
  target_type = "logdna"
  logdna_endpoint {
    target_crn    = ibm_resource_instance.logdnaat_instance.crn
    ingestion_key = ibm_resource_key.ingestion_key.credentials.ingestion_key
  }
  name = "tor-at-target"
}

## Create the ingestion key for Activity Tracker
resource "ibm_resource_key" "ingestion_key" {
  name                 = "activity_tracker_tor_ingestion_key"
  role                 = "Administrator"
  resource_instance_id = ibm_resource_instance.logdnaat_instance.id
}


## Route events from specified locations to activity tracker instance in Toronto
resource "ibm_atracker_route" "atracker_route" {
  depends_on = [
    ibm_atracker_settings.atracker_settings
  ]
  name = "canada-route"
  rules {
    target_ids = [ibm_atracker_target.atracker_logdna_target.id]
    locations  = var.activity_tracker_route_sources
  }
  lifecycle {
    # Recommended to ensure that if a target ID is removed here and destroyed in a plan, this is updated first
    create_before_destroy = true
  }
}

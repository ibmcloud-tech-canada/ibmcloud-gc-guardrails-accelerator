## Create Access Groups for Admins and Users 
#Ref: Based on https://github.com/cloud-native-toolkit/terraform-ibm-account-access-group
#Ref: https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-shared-account-access-management

locals {
  cloud-organization-admins      = "CLOUD_ORGANIZATION_ADMINS"
  cloud-organization-admins-desc = "Account level administrative access"
  cloud-network-admins           = "CLOUD_NETWORK_ADMINS"
  cloud-network-admins-desc      = "Administrative access to VPC infrastructure"
  cloud-security-admins          = "CLOUD_SECURITY_ADMINS"
  cloud-security-admins-desc     = "Administrative access to SCC, IAM and viewer access to account management "
  cloud-billing-admins           = "CLOUD_BILLING_ADMINS"
  cloud-billing-admins-desc      = "Access to account billing information"
  cloud-devops                   = "CLOUD_DEVOPS"
  cloud-devops-desc              = "Access to run devops processes"
  cloud-developers               = "CLOUD_DEVELOPERS"
  cloud-developers-desc          = "Access to resources needed to develop applications"
}

resource "ibm_iam_access_group" "org_admins" {
  name        = local.cloud-organization-admins
  description = local.cloud-organization-admins-desc
}
resource "ibm_iam_access_group" "billing_admins" {
  name        = local.cloud-billing-admins
  description = local.cloud-billing-admins-desc
}
resource "ibm_iam_access_group" "network_admins" {
  name        = local.cloud-network-admins
  description = local.cloud-network-admins-desc
}
resource "ibm_iam_access_group" "security_admins" {
  name        = local.cloud-security-admins
  description = local.cloud-security-admins-desc
}
resource "ibm_iam_access_group" "devops" {
  name        = local.cloud-devops
  description = local.cloud-devops-desc
}
resource "ibm_iam_access_group" "developers" {
  name        = local.cloud-developers
  description = local.cloud-developers-desc
}

# cloud-organization-admins

# All IAM-Managed resources in account
resource "ibm_iam_access_group_policy" "admin_policy_1" {
  access_group_id = ibm_iam_access_group.org_admins.id
  roles           = ["Administrator"]
  /*resources {
    resource_group_id = data.ibm_resource_group.group.id    
  }*/
}

# All Account Management services
resource "ibm_iam_access_group_policy" "admin_policy_2" {
  access_group_id    = ibm_iam_access_group.org_admins.id
  roles              = ["Administrator"]
  account_management = true
}

# API Key and Service ID creator
resource "ibm_iam_access_group_policy" "admin_policy_3" {
  access_group_id = ibm_iam_access_group.org_admins.id
  roles           = ["Service ID creator", "User API key creator", "Administrator"]
  resource_attributes {
    name     = "service_group_id"
    operator = "stringEquals"
    value    = "IAM"
  }
}

# Support cases
resource "ibm_iam_access_group_policy" "admin_policy_4" {
  access_group_id = ibm_iam_access_group.org_admins.id
  roles           = ["Editor"]
  resources {
    service = "support"
  }
}

# Cloud Object Storage, bucket management. It is not covered by the 
# general "All IAM enabled services"
resource "ibm_iam_access_group_policy" "admin_policy_5" {
  access_group_id = ibm_iam_access_group.org_admins.id
  roles           = ["Manager"]
  resources {
    service = "cloud-object-storage"
  }
}

# cloud-billing-admins

resource "ibm_iam_access_group_policy" "billing_policy_1" {
  access_group_id = ibm_iam_access_group.billing_admins.id
  roles           = ["Administrator"]
  resources {
    service = "billing"
  }
}

resource "ibm_iam_access_group_policy" "billing_policy_2" {
  access_group_id = ibm_iam_access_group.billing_admins.id
  roles           = ["Editor"]
  resources {
    service = "support"
  }
}

# cloud-network-admins

resource "ibm_iam_access_group_policy" "network_policy_1" {
  access_group_id = ibm_iam_access_group.network_admins.id
  roles           = ["Administrator", "IP Spoofing Operator"]
  resources {
    service = "is"
  }
}

resource "ibm_iam_access_group_policy" "network_policy_2" {
  access_group_id = ibm_iam_access_group.network_admins.id
  roles           = ["Viewer"]
}

resource "ibm_iam_access_group_policy" "network_policy_3" {
  access_group_id = ibm_iam_access_group.network_admins.id
  roles           = ["Editor"]
  resources {
    service = "support"
  }
}

# cloud-security-admins

resource "ibm_iam_access_group_policy" "security_policy_1" {
  access_group_id    = ibm_iam_access_group.security_admins.id
  roles              = ["Administrator"]
  account_management = true
}


# Access to Security and Compliance Center Scans
resource "ibm_iam_access_group_policy" "security_policy_2" {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Administrator"]
  resources {
    service = "compliance"
  }
}

# Allow creation of Service IDs and API Keys.  This may not be needed
# if CLOUD_ORGANIZATION_ADMIN can provide credentials for scans
resource "ibm_iam_access_group_policy" "security_policy_4" {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Administrator", "User API key creator", "Service ID creator"]
  resource_attributes {
    name     = "service_group_id"
    operator = "stringEquals"
    value    = "IAM"
  }
}

resource "ibm_iam_access_group_policy" "security_policy_5" {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Administrator"]
  resources {
    service = "iam-groups"
  }
}

resource "ibm_iam_access_group_policy" "security_policy_6" {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Viewer"]
}

# Visibility into clusters
resource "ibm_iam_access_group_policy" "security_policy_7" {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Viewer", "Reader"]

  resources {
    service = "containers-kubernetes"
  }
}

# Administratory for Activity Tracker
resource "ibm_iam_access_group_policy" "security_policy_8" {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Editor", "Administrator"]
  resources {
    service = "logdnaat"
  }
}


resource "ibm_iam_access_group_policy" "devops_policy_1" {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Viewer"]
}

resource "ibm_iam_access_group_policy" "devops_policy_2" {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Editor", "Manager"]
  resources {
    service = "logdnaat"
  }
}

resource "ibm_iam_access_group_policy" "devops_policy_3" {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Administrator", "Manager"]

  resources {
    service = "containers-kubernetes"
  }
}

resource "ibm_iam_access_group_policy" "devops_policy_4" {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Viewer", "Operator"]
  resources {
    service = "is"
  }
}

resource "ibm_iam_access_group_policy" "devops_policy_5" {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Administrator"]
  resources {
    service = "toolchain"
  }
}

resource "ibm_iam_access_group_policy" "devops_policy_6" {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Manager","Editor"]
  resources {
    service = "continuous-delivery"
  }
}

resource "ibm_iam_access_group_policy" "devops_policy_7" {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Editor"]
  resources {
    service = "support"
  }
}

resource "ibm_iam_access_group_policy" "devops_policy_8" {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Manager","Administrator"]
  resources {
    service = "schematics"
  }
}

# Cloud Object Storage, bucket management. 
resource "ibm_iam_access_group_policy" "devops_policy_9" {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Manager"]
  resources {
    service = "cloud-object-storage"
  }
}



# cloud-developers

resource "ibm_iam_access_group_policy" "developer_policy_1" {
  access_group_id = ibm_iam_access_group.developers.id
  roles           = ["Administrator", "Manager"]

  resources {
    service = "containers-kubernetes"
  }
}

resource "ibm_iam_access_group_policy" "developer_policy_2" {
  access_group_id = ibm_iam_access_group.developers.id
  roles           = ["Editor"]
  resources {
    service = "support"
  }
}

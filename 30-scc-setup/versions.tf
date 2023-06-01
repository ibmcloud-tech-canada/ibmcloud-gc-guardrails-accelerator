##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~>1.53"
    }
  }
  required_version = "~>1.1"
}


# Uncomment ibmcloud_api_key if you want to pass it as variable
provider "ibm" {
 ibmcloud_api_key = var.ibmcloud_api_key
 region = local.region
}

##############################################################################


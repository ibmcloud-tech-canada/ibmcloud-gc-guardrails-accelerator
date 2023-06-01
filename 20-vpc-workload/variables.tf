variable "ibmcloud_api_key" {
  description = "API Key with authorization to create the resources in this script"
  type        = string
  sensitive   = true
}

# Address prefixes for the workload vpc
# This range require IP planning and should be unique for each customer
#
# If generated automatically, each zone in a VPC would have
# 16,384 (mask 255.255.192.0 or /18) IP addresses.  Keeping this default range, an 
# example is:
#
# vpc_cidrs = ["10.10.0.0/18","10.20.0.0/18", "10.30.0.0/18"]
variable "vpc_cidrs" {
  type        = list(string)
  description = "CIDR for each VPC zone."
}


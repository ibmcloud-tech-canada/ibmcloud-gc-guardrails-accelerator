# Government of Canada Guadrails Accelerator for IBM Cloud

## Overview

These instructions and terraform automation provide a prescriptive method to prepare an account for Government of Canada Profile 1 [Cloud Guardrails](https://github.com/canada-ca/cloud-guardrails). They assist in implementing the technical controls for these Cloud Guardrails:

* 01 Protect root/global admins account
* 02 Management of administrative privileges
* 03 Cloud console access
* 04 Enterprise Monitoring accounts
* 05 Data location
* 06 Protection of data-at-rest (with customer-provided encryption)
* 07 Protection of data-in-transit 
* 08 Segment and separate
* 09 Network security services
* 11 Logging and monitoring
* 12 Configuration of cloud marketplaces

This is a good foundation for all Guardrails profiles which are described in Page 20 [here](https://wiki.gccollab.ca/images/7/75/GC_Cloud_Connection_Patterns.pdf).

## Contacts

For assistance, reach out by email to jared.killoran@ibm.com or behzadk@ca.ibm.com 

## Pre-Requisites

1. A new account.  This account can be within an Enterprise or standalone.
1. Create an API Key for the account owner.  This API Key will be used to run the terraform that sets up the landing zone.
1. This has been tested with terraform version 1.1.  For instructions on installing terraform, see https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-getting-started 



## How to run

The automation for setting up your IBM Cloud environment has been divided into three steps.  More detail on each step can be found in the README.md for the steps. [00-account-setup](./00-account-setup/README.md) creates some base resources used by [20-scc-setup](/20-scc-setup/README.md) and [30-workoad](./30-workload/README.md).  


| Step | Description |
|----------|------------|
| [00-account-setup](./00-account-setup/README.md)| Account settings are hardened, such as placing restrictions creating API Keys and Service Ids.  In addition, IBM Cloud Storage and Key Protect instances are created.  IBM Cloud Storage can be used for storing Network Flow Logs, Security and Compliance Center reports and other artifacts, while Key Protect is used to generate keys for encrypting your data at rest.  This step also sets up a predefined set of Access Groups with assigned roles.  This is intended as a starting point and can be refined for your organizational structure and responsibilities. ||
| [20-vpc-workoad](./20-vpc-workload/README.md) (Optional) | Sets up the initial VPC infrastructure for your workload.  It contains one VPC with configurable address space.  It also sets up Network Flow Logs to capture inbound and outbound events for your VPC.  The Flow Logs are stored in another encrypted Cloud Object Storage bucket provisioned by this terraform. |
| [30-scc-setup](./30-scc-setup/README.md) (Optional) | Prepares the Security and Compliance Center for configuring Posture Management scans of your environment.  It will create an encrypted Cloud Object Storage bucket for Security and Compliance Center reports and enable service-to-service authorization so that Security and Compliance Center can write to the bucket. There are some manual steps to complete Security and Compliance Center setup after running the terraform. Reach out to contacts for assistance. |


Each step contains terraform templates that can be run using:

1. `terraform init` to initialize the Terraform working directory
1. `terraform plan` to view the resources that will be created
1. `terraform apply` to run the terraform template.  This command will show you the same output as `terraform plan` and give you an opportunity to abort before it executes.

You must provide an API Key to each step.  To do this, copy the `terraform.tfvars.template` file in each step to `terraform.tfvars` and then fill in the values of the `ibmcloud_api_key` variable.  Some steps have optional customizations - these can also be set in the `terraform.tfvars` file.



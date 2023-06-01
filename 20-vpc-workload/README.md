# 20-vpc-workload

This terraform depends on [00-account-setup](../00-account-setup/) and must be run within the folder structure as it will look for output from 00-account-setup.

## What it Creates

The terraform creates the following:

1. A VPC in the specified region using specified address prefixes for each zone.
1. A Cloud Object Storage (COS) bucket encrypted with a new Key from Key Protect (KP) for storing Flow Logs.  It uses the COS and KP instances created in [00-account-setup](../00-account-setup/) 
1. A Service-to-Service authorization to permit Flow Logs to write to COS
1. Flow Logs for the VPC

Note, the VPC will have a default network Access Control List (ACL) and Security Group that are created automatically by the IBM terraform provider when provisioning a VPC.  ACLs control traffic to and from subnets, while Security Groups control traffic to and from Virtual Server Instance (VSI) interfaces.  The default ACL allows all inbound and outbound traffic, while the default Security Group restricts inbound traffic within the Security Group, but also allows all outbound traffic.  Since there are no subnets or VSIs created by this terraform, this poses no risk, but it will be flagged by the Security and Compliance Center reports.  When subnets and VSIs or Kubernetes/OpenShift clusters are created, the appropriate ACLs and Security Groups should be created to protect these.


## To Run

Copy `terraform.tfvars.template` to `terraform.tfvars` and provide your **ibmcloud_api_key**. 

Run the terraform using:

1. `terraform init` to initialize the Terraform working directory
1. `terraform plan` to view the resources that will be created
1. `terraform apply` to run the terraform template.  This command will show you the same output as `terraform plan` and give you an opportunity to abort before it executes.



output "resource_group_name" {
  value = ibm_resource_group.group.name
}

output "region" {
  value = var.region
}

output "cos_name" {
  value = ibm_resource_instance.cos.name
}

output "key_management_name" {
  value = ibm_resource_instance.key_protect_instance.name
}

output "prefix" {
  value = var.prefix
}

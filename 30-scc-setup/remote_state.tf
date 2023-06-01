data "terraform_remote_state" "setup" {
  backend = "local"

  config = {
    path = "${path.cwd}/../00-account-setup/terraform.tfstate"
  }
}

locals {
    kms_name = data.terraform_remote_state.setup.outputs.key_management_name
    cos_name = data.terraform_remote_state.setup.outputs.cos_name

    resource_group_name = data.terraform_remote_state.setup.outputs.resource_group_name
    prefix = data.terraform_remote_state.setup.outputs.prefix
    region = data.terraform_remote_state.setup.outputs.region
}
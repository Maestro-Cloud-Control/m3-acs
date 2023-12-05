provider "m3" {}

resource "m3_instance" "my-server" {
  image = "Ubuntu20.04_64-bit"
  instance_name = "chef_epc"
  region_name = var.m3_regionName
  tenant_name = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key_name = var.key_name
  owner = var.m3_owner
  chef_profile = "chef-epc"
  additional_data = {
    private_key = var.m3_private_key
  }
}

variable "m3_private_key" {
  description = "Private key file for acs git repo"
  sensitive = "true"
}
variable "tenant_name" {
  description = "Tenant name"
}
variable "region_name" {
  description = "Region name"
}
variable "key_name" {
  description = "key_name"
}
variable "owner" {
  description = "owner"
}

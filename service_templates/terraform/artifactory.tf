provider "m3" {}

resource "m3_instance" "my-server" {
  image = "CentOS7_64-bit"
  name = "artifactory"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "artifactory_acs"
  additional_data = {
    login_password = var.m3ahe_login_password
  }
}

variable "m3ahe_login_password" {
  description = "m3_5ahe_::)Password for the created database"
  sensitive = "true"
}
variable "m3_tenantName" {
  description = "Tenant name"
}
variable "m3_regionName" {
  description = "Region name"
}
variable "key_name" {
  description = "key_name"
}
variable "m3_owner" {
  description = "owner"
}
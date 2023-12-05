provider "m3" {}

resource "m3_instance" "my-server" {
  image = "Ubuntu20.04_64-bit"
  name = "graylogserver"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "graylog2_epc"
  additional_data = {
    login_password = var.m3ahe_login_password
    eo_password = var.m3ahe_eo_password
  }
}

variable "m3ahe_login_password" {
  description = "m3_5ahe_::)Password for login to the service"
  sensitive = "true"
}
variable "m3ahe_eo_password" {
  description = "m3_5ahe_::)Password for eo user login to the service"
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
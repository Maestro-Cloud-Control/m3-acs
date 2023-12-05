provider "m3" {}
resource "m3_instance" "my-server" {
  image = "Ubuntu22.04_64-bit"
  name = "camunda"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "camunda"
  additional_data = {
    admin_password = var.m3ahe_admin_password
    manager_password = var.m3ahe_manager_password
  }
}

variable "m3ahe_manager_password" {
  description = "Password for login to the service"
  sensitive = "true"
}
variable "m3ahe_admin_password" {
  description = "Password for login to the service"
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

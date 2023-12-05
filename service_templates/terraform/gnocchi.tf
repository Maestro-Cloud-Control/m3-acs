provider "m3" {}
resource "m3_instance" "my-server" {
  image = "ubuntu20.04_64-bit"
  instance_name = "gnocchi"
  region_name = var.m3_regionName
  tenant_name = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key_name = var.key_name
  owner = var.m3_owner
  chef_profile = "gnocchi-server"
  additional_data = {
    admin_password = var.m3ah_admin_password
    db_user_password = var.m3ah_db_user_password
    db_root_password = var.m3ah_db_root_password
  }
}

variable "m3ah_admin_password" {
  description = "Password for login to the service"
  sensitive = "true"
}
variable "m3ah_db_user_password" {
  description = "Password for gnocchi db"
  sensitive = "true"
}
variable "m3ah_db_root_password" {
  description = "Root password for sql db"
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
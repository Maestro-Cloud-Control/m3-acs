provider "m3" {}

resource "m3_instance" "my-server" {
  image = "Ubuntu20.04_64-bit"
  name = "mongodb"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "mongodb"
  additional_data = {
    mongodb_user_password = var.m3ahe_mongodb_user_password
  }
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
variable "m3ahe_mongodb_user_password" {
  description = "m3_5ahe_::)Password for the created database"
  sensitive = "true"
}
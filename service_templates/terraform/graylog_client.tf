provider "m3" {}

resource "m3_instance" "my-server" {
  image = "Ubuntu20.04_64-bit"
  instance_name = "graylog-client"
  region_name = var.m3_regionName
  tenant_name = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key_name = var.key_name
  owner = var.m3_owner
  chef_profile = "graylog-client"
  additional_data = {
    server_fqdn = var.m3_server_fqdn
  }
}

variable "m3_server_fqdn" {
  description = "Graylog server fqdn"
}
variable "tenantName" {
  description = "Tenant name"
}
variable "regionName" {
  description = "Region name"
}
variable "key_name" {
  description = "key_name"
}
variable "owner" {
  description = "owner"
}

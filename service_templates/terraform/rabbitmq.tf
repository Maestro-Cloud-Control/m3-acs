provider "m3" {}

resource "m3_instance" "my-server" {
  image = "Ubuntu20.04_64-bit"
  name = "rabbitmq"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "sqs"
  additional_data = {
    login_username = var.m3_login_username
    login_password = var.m3ahe_login_password
  }
}

variable "m3_login_username" {
  description = "User name for login to the service"
  default = "admin"
}
variable "m3ahe_login_password" {
  description = "Password for login to the service"
  sensitive = "true"
}
variable "m3_regionName" {
  description = "Region"
}
variable "m3_tenantName" {
  description = "Tenant"
}
variable "key_name" {
  description = "key_name"
}
variable "m3_owner" {
  description = "owner"
}
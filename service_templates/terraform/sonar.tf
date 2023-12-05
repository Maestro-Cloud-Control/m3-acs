provider "m3" {}
resource "m3_instance" "my-server" {
  image = "Ubuntu20.04_64-bit"
  name = "sonarqube"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "sonar_acs"
  additional_data = {
    login_password = var.m3ahe_login_password
    db_user_password = var.m3ah_db_user_password
    db_root_password = var.m3ah_db_root_password
  }
}
variable "m3ah_db_user_password" {
  description = "Password for sonar db"
  sensitive = "true"
}
variable "m3ah_db_root_password" {
  description = "Root db password"
  sensitive = "true"
}
variable "m3ahe_login_password" {
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
provider "m3" {}

resource "m3_instance" "my-server" {
  image = "Ubuntu20.04_64-bit"
  name = "mariadb"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "mariadb_rds"
  additional_data = {
    mariadb_root_password = var.m3ah_mariadb_root_password
    mariadb_user_password = var.m3ahe_mariadb_user_password
    mariadb_init_script = var.m3_mariadb_init_script
    mariadb_db_name = var.m3_mariadb_db_name
    mariadb_username = var.m3_mariadb_username
  }
}

variable "m3_mariadb_init_script" {
  description = ""
  default = ""
}
variable "m3ahe_mariadb_user_password" {
  description = "m3_5ahe_::)Password for the created database"
  sensitive = "true"
}
variable "m3ah_mariadb_root_password" {
  description = "m3_5ah_::)Root db password"
  sensitive   = "true"
}
variable "m3_mariadb_db_name" {
  description = "Name for the created database"
  default = "admin_db"
}
variable "m3_mariadb_username" {
  description = "Username for administering the created database"
  default = "admin"
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
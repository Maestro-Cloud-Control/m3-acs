provider "m3" {}

resource "m3_instance" "my-server" {
  image = "Ubuntu20.04_64-bit"
  name = "lampstack"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "lamp"
  additional_data = {
    mysql_root_password = var.m3ah_mysql_root_password
    mysql_user_password = var.m3ahe_mysql_user_password
    mysql_db_name = var.m3_mysql_db_name
    mysql_username = var.m3_mysql_username
    app_gitrepo = var.m3_app_gitrepo
    app_gitbranch = var.m3_app_gitbranch
  }
}

variable "m3ahe_mysql_user_password" {
  description = "m3_5ahe_::)Password for the created database"
  sensitive = "true"
}
variable "m3ah_mysql_root_password" {
  description = "m3_5ah_::)Root db password"
  sensitive   = "true"
}
variable "m3_mysql_db_name" {
  description = "Name for the created database"
  default = "php_mysql_crud"
}
variable "m3_mysql_username" {
  description = "Username for administering the created database"
  default = "admin"
}
variable "m3_app_gitrepo" {
  description = "Git repo wrepe app store"
  default = ""
}
variable "m3_app_gitbranch" {
  description = "Git branch of git repo"
  default = ""
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
provider "m3" {}

resource "m3_instance" "my-server" {
  image = "W2019Std"
  instance_name = "rdb-mssql"
  region_name = var.region_name
  tenant_name = var.tenant_name
  shape = "MEDIUM"
  enable_chef = true
  key_name = var.key_name
  owner = var.owner
  chef_profile = "mssql_rds"
  additional_data = {
    mssql_root_password = var.m3ah_mssql_root_password
    mssql_user_password = var.m3ahe_mssql_user_password
    mssql_init_script = var.m3_mssql_init_script
    mssql_db_name = var.m3_mssql_db_name
    mssql_username = var.m3_mssql_username
  }
}

variable "mssql_init_script" {
  description = ""
  default = ""
}
variable "mssql_user_password" {
  description = "Password for the created database"
  sensitive = "true"
}
variable "mssql_root_password" {
  description = "Root db password"
}
variable "mssql_db_name" {
  description = "Name for the created database"
  default = "admin_db"
}
variable "mssql_username" {
  description = "Username for administering the created database"
  default = "admin"
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
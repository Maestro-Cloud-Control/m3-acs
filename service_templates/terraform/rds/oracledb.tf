provider "m3" {}

resource "m3_instance" "my-server" {
  image = "OracleLinux7_64-bit"
  instance_name = "rdb-oracle"
  region_name = var.m3_regionName
  tenant_name = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key_name = var.key_name
  owner = var.m3_owner
  chef_profile = "oracle_rds"
  additional_data = {
    oracle_root_password = var.m3ah_oracle_root_password
    oracle_user_password = var.m3ahe_oracle_user_password
    oracle_init_script = var.m3_oracle_init_script
    oracle_db_name = var.m3_oracle_db_name
    oracle_username = var.m3_oracle_username
  }
}

variable "oracle_init_script" {
  description = ""
  default = ""
}
variable "oracle_user_password" {
  description = "Password for the created database"
  sensitive = "true"
}
variable "oracle_root_password" {
  description = "Root db password"
}
variable "oracle_db_name" {
  description = "Name for the created database"
  default = "admin_db"
}
variable "oracle_username" {
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

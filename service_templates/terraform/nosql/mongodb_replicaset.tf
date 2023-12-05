provider "m3" {}

resource "m3_instance" "mongodb-arbiter" {
  image = "Ubuntu20.04_64-bit"
  name = "mongodbarbiter"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "mongodb_arbiter"
  additional_data = {
    
  }
}

resource "m3_instance" "mongodb-primary" {
  image = "Ubuntu20.04_64-bit"
  name = "mongodbprimary"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "mongodb_primary"
  additional_data = {
    
  }
}

resource "m3_instance" "mongodb-secondary" {
  image = "Ubuntu20.04_64-bit"
  name = "mongodbsecondary"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "mongodb_secondary"
  additional_data = {
    
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

# variable "m3ahe_mongodb_user_password" {
#   description = "m3_5ahe_::)Password for the created database"
#   sensitive = "true"
# }
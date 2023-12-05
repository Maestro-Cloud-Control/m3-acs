provider "m3" {}

resource "m3_instance" "k8s_master" {
  image = "Ubuntu22.04_64-bit"
  name = "k8smaster"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "LARGE"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "k8s_master"
  additional_data = {
    
  }
}

resource "m3_instance" "k8s_node1" {
  image = "Ubuntu22.04_64-bit"
  name = "k8snode1"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "LARGE"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "k8s_node"
  additional_data = {
    
  }
}

resource "m3_instance" "k8s_node2" {
  image = "Ubuntu22.04_64-bit"
  name = "k8snode2"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "LARGE"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "k8s_node"
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

# variable "m3ahe_user_password" {
#   description = "m3_5ahe_::)Password for the created database"
#   sensitive = "true"
# }
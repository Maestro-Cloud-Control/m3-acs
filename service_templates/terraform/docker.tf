provider "m3" {}

resource "m3_instance" "my-server" {
  image = "Ubuntu20.04_64-bit"
  name = "docker"
  region = var.m3_regionName
  tenant = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key = var.key_name
  owner = var.m3_owner
  chef_profile = "docker_service19"
  additional_data = {
    swarmpit_login_password = var.m3ahe_swarmpit_login_password
    cluster_token = var.m3a_cluster_token
    cluster_id = var.m3a_cluster_id
    node_certificate = var.m3a_node_certificate
    node_private_key = var.m3a_node_private_key
    project_certificate = var.m3a_project_certificate
  }
}

variable "m3ahe_swarmpit_login_password" {
  description = "Password for login to the service"
  sensitive = "true"
}
variable "m3ah_cluster_token" {
  description = "Join tokens are secrets that allow a node to join the swarm"
  sensitive = "true"
}
variable "m3ah_cluster_id" {
  description = "Swarm cluster id"
}
variable "m3ah_node_certificate" {
  description = "Node certificate"
  sensitive = "true"
}
variable "m3ah_node_private_key" {
  description = "Private key"
  sensitive = "true"
}
variable "m3ah_project_certificate" {
  description = "Project certificate"
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

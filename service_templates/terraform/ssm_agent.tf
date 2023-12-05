provider "m3" {}

resource "m3_instance" "my-server" {
  image = "Ubuntu18.04_64-bit"
  instance_name = "ssm_agent"
  region_name = var.m3_regionName
  tenant_name = var.m3_tenantName
  shape = "MEDIUM"
  enable_chef = true
  key_name = var.key_name
  owner = var.m3_owner
  chef_profile = "cloud_watch-client"
  additional_data = {
    activation_id = var.m3_activation_id
    aws_region = var.m3_aws_region
    activation_code = var.m3_activation_code
  }
}

variable "m3_activation_id" {
  description = "SSM agent activation id"
}
variable "m3_aws_region" {
  description = "SSM agent region"
}
variable "m3_activation_code" {
  description = "SSM agent activation code"
  sensitive = "true"
}
variable "activation_id" {
  description = "activation_id"
}
variable "aws_region" {
  description = "aws_region"
}
variable "activation_code" {
  description = "activation_code"
}
variable "key_name" {
  description = "key_name"
}
variable "owner" {
  description = "owner"
}





#
# Cookbook Name:: sonar_acs
# Recipe:: default
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

eporch2_meta_data 'meta_data' do
  name 'sonar'
  action :nothing
end.run_action(:update)

include_recipe 'sonar_acs::ssl'
include_recipe 'corretto-java'
include_recipe 'sonar_acs::install_and_conf_a_sonar_db'
include_recipe 'sonar_acs::install_sonar'

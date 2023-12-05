#
# Cookbook:: lamp
# Recipe:: default
#
# Copyright:: 2023, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'lamp'
  action :nothing
end.run_action(:update)

include_recipe 'lamp::apache'
include_recipe 'lamp::php'
include_recipe 'lamp::mysql'
include_recipe 'lamp::application'
include_recipe 'lamp::ssl'
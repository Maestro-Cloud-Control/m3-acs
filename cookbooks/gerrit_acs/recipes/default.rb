#
# Cookbook:: gerrit_acs
# Recipe:: default
#
# Copyright:: 2023, , All Rights Reserved.

package %w(default-jre nginx apache2-utils)
# package 'default-jre'

eporch2_meta_data 'meta_data' do
  name 'gerrit'
  action :nothing
end.run_action(:update)

include_recipe 'gerrit_acs::install_and_conf_gerrit'
include_recipe 'gerrit_acs::conf_revers_proxy'
# include_recipe 'gerrit_acs::ssl'

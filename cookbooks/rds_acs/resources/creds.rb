#
# Cookbook Name:: rds_acs
# Resource Name:: creds
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

unified_mode true

action :get_attribute do
  
  type = nil
  if data_bag(node['name']).include? 'rdb'
    node.run_state['rds_mode'] = 'service'
    
    eporch2_meta_data 'meta_data' do
      name 'rdb'
      action :nothing
    end.run_action(:update)
    
    node['metadata']['rdb'].each do |attribute, _value|
      type = attribute.split('_')[0]
      Chef::Log.info("db type is: #{type}")
      break
    end
    
    collect_rds_attributes(type)

  else
    node.run_state['rds_mode'] = 'role'
    node.run_state['root_pass'] = node['rds_acs']['root_password']
  end
end

action_class do
  include Eporch2::Helpers

  def collect_rds_attributes(type)
    unless node['metadata']['rdb']["#{type}_root_password"].nil?
      node.run_state['root_pass'] = node['metadata']['rdb']["#{type}_root_password"]
      
      Chef::Log.info("db root password from databag: #{node['metadata']['rdb']["#{type}_root_password"]}")
      Chef::Log.info("db root password: #{node.run_state['root_pass']}")
    end

    unless node['metadata']['rdb']["#{type}_user_password"].nil?
      node.run_state['user_pass'] = node['metadata']['rdb']["#{type}_user_password"]
      # Chef::Log.info("db user password: #{node.run_state['user_pass']}")
    end

    unless node['metadata']['rdb']["#{type}_init_script"].nil?
      node.run_state['sql_init_script'] = node['metadata']['rdb']["#{type}_init_script"]
    end

    if type == 'mssql'
      node.default['rds_acs']['mssql']['admin'] = node['metadata']['common']['owner_name']
    end

    unless node['metadata']['rdb']["#{type}_db_name"].nil?
      node.run_state['db_name'] = node['metadata']['rdb']["#{type}_db_name"]
    end

    unless node['metadata']['rdb']["#{type}_username"].nil?
      node.run_state['db_user'] = node['metadata']['rdb']["#{type}_username"]
    end
  end

end

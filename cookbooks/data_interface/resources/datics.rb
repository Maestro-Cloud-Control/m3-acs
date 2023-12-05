# Cookbook Name:: data_interface
# Resources:: datics
#
# Copyright 2021
#
# All rights reserved - Do Not Redistribute
#

property :service, String, name_property: true
property :data, Hash

action :push do
  node.normal['datics'][new_resource.service] = new_resource.data
  unless node['metadata']['common']['region'].nil?
    node.normal['region'] = node['metadata']['common']['region']
  end
  unless node['metadata']['common']['project_id'].nil?
    node.normal['project_id'] = node['metadata']['common']['project_id']
  end
end

action :pull do
  node.run_state['datics'] = {} if node.run_state['datics'].nil?
  datics_search_zone = new_resource.service == '' ? 'datics:*' : "datics_#{new_resource.service}:*"
  query = search(:node,
    "region:#{node['metadata']['common']['region']} \
      AND project_id:#{node['metadata']['common']['project_id']} \
      AND #{datics_search_zone} \
      AND NOT name:#{node['name']}",
    filter_result: {
      name: ['name'],
      fqdn: ['fqdn'],
      data: ['datics'],
    }
  )
  unless query.nil?
    query.each do |result|
      result['data'].each do |service, data|
        data = {} if data.nil?
        node.run_state['datics'][service] = {
          result['fqdn'] => data,
        }
        Chef::Log.info("[datics] Found #{service} on #{result['name']}")
        node.run_state['datics'][service][result['fqdn']]['source'] = result['name']
      end
    end
  end
end

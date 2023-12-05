#
# Cookbook Name:: eporch2
# Resource:: chef_run_list
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

unified_mode true

property :roles, String
property :name, String, default: ''

action :update do
  new_run_list = [Chef::RunList::RunListItem.new('role[base]')]

  unless new_resource.roles.nil?
    Chef::Log.info('Refreshing chef-client`s roles in run_list')
    new_run_list = new_resource.roles.split(',').uniq.inject(new_run_list) do |memo, string|
      Chef::Log.debug("Processing #{string}")
      memo.push(Chef::RunList::RunListItem.new("role[#{string}]"))
    end
  end

  Chef::Log.info("Refreshed run_list: #{new_run_list.map(&:name).join(', ')}")

  old_run_list_arr = node.run_list.run_list_items.map(&:name)
  new_run_list_arr = new_run_list.map(&:name)

  unless (removed_items = old_run_list_arr.difference(new_run_list_arr)).empty?
    node.override['run_list']['removed_items'] = removed_items
    Chef::Log.info("Removed from the runlist the following values: #{removed_items.join(', ')}")
  end

  unless (added_items = new_run_list_arr.difference(old_run_list_arr)).empty?
    node.override['run_list']['added_items'] = added_items
    Chef::Log.info("Added to the runlist the following values: #{added_items.join(', ')}")
  end

  node.override['force_run_needed'] = (!added_items.empty? or !removed_items.empty?)
  node.run_list(new_run_list)
end

#
# Cookbook Name:: eporch2
# Resource:: meta_data
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

unified_mode true

property :name, String

action :update do
  if data_bag(node['name']).include? new_resource.name
    Chef::Log.info("Found data bag for #{node['name']}")
    begin
      if ::File.exist?(node['chef_client']['config']['encrypted_data_bag_secret'])
        Chef::Log.info("Trying to decrypt data bag item #{new_resource.name} with stored databag secret")
        metadata = metadata_from_databag(node['name'], new_resource.name)
      else
        raise 'No local stored secret found'
      end
    rescue => e
      Chef::Log.warn(e.message)
      secret = refresh_secret
      begin
        Chef::Log.info("Trying to decrypt data bag item #{new_resource.name} with refreshed key.")
        metadata = metadata_from_databag(node['name'], new_resource.name, secret)
      rescue
        Chef::Log.info("Failed to decrypt data bag item #{new_resource.name}.")
      end
    end
  else
    Chef::Log.info("Data bag item #{new_resource.name} not found for #{node['name']}.")
  end
  node.default['metadata'][new_resource.name] = metadata
  # node.normal['startrun_url'] = node['metadata']['common']['lastrun_url']
end

action_class do
  include Eporch2::Helpers

  def metadata_from_databag(databag, item, secret = nil)
    bag = data_bag_item(databag, item, secret).to_hash
    bag.delete('id')
    bag
  end

  def refresh_secret
    begin
      secret = ::File.read("#{node['chef_client']['conf_dir']}/file_with_databag_secret").strip

      ::File.write(node['chef_client']['config']['encrypted_data_bag_secret'], secret)
      ::File.delete("#{node['chef_client']['conf_dir']}/file_with_databag_secret")

      secret
    rescue
      Chef::Log.warn('Failed to refresh secret -> file with secret from certbundle not found')
      return nil
    end
  end
end


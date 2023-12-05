#
# Cookbook:: k8s
# Recipe:: k8s node
#
# Copyright:: 2023, All Rights Reserved.

# Delay for 240 seconds
ruby_block 'sleep for 240 seconds' do
  block do
    sleep 240
  end
  action :run
end

nodes = search(:node, 'role:k8s_master')

# Iterate through the search results
nodes.each do |node|
  # Access node attributes
  fqdn = node['fqdn']
  Chef::Log.info("fqdn: #{fqdn}")

  token = node['k8s']['node']['token']
  Chef::Log.info("token: #{token}")

  if token.empty?
    Chef::Log.debug('TOKEN is empty')
  else
    bash 'run RKE2 agent installer' do
      code <<-EOH
        curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
      EOH
      action :run
    end
  
    directory '/etc/rancher/rke2/' do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
      recursive true
    end
    
    template "/etc/rancher/rke2/config.yaml" do
      source "node/config.yaml.erb"
      owner 'root'
      group 'root'
      mode '0755'
      variables(
          node_token: token,
          k8s_master_fqdn: fqdn
        )
      action :create_if_missing
      # sensitive true
    end
  
    service 'rke2-agent' do
      supports restart: true, reload: true, status: true
      action [:enable, :start]
    end
  end 
end



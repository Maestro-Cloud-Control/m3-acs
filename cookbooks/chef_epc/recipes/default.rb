#
# Cookbook:: chef_epc
# Recipe:: default
#
# Copyright:: 2023, All Rights Reserved.

remote_file '/tmp/chef-server.deb' do
  source node['chef']['epc']['package']['source']
  action :create
end

dpkg_package 'chef-server.deb' do
  source '/tmp/chef-server.deb'
  action :install
end

directory node['chef']['epc']['conf']['dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# set value of chef conf 
if node['metadate']['chef_epc']['domain_name'].empty?
  api_fqdn = node['hostname']
  path_to_ssl_certificate = '/var/opt/opscode/nginx/ca/fullchain.pem'
  path_to_ssl_certificate_key = '/var/opt/opscode/nginx/ca/privkey.pem'
else
  api_fqdn = node['metadate']['chef_epc']['domain_name']
  path_to_ssl_certificate = "/etc/letsencrypt/live/#{node['metadate']['chef_epc']['domain_name']}/fullchain.pem"
  path_to_ssl_certificate_key = "/etc/letsencrypt/live/#{node['metadate']['chef_epc']['domain_name']}/privkey.pem"

  package 'snapd' do
    action :install
  end
  
  # Ensure snapd service is enabled and started
  service 'snapd' do
    action [:enable, :start]
  end
  
  # Install Certbot using snap in classic mode
  execute 'install_certbot' do
    command 'snap install --classic certbot'
    action :run
  end

  bash 'generate ssl cert via certbot' do
    code <<-EOH
      certbot certonly --standalone --domains #{node['metadate']['chef_epc']['domain_name']} --register-unsafely-without-email
    EOH
    action :run
  end
end

chef_epc_configure_chef_server 'configure_chef_server' do 
  api_fqdn                      api_fqdn
  path_to_ssl_certificate       path_to_ssl_certificate
  path_to_ssl_certificate_key   path_to_ssl_certificate_key
  action                        :configure
  not_if                        { node['chef']['epc']['conf']['status'] == 'configured' }
end


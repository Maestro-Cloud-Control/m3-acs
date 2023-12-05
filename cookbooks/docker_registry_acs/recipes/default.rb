#
# Cookbook Name:: docker_registry_acs
# Recipe:: default
#
# Copyright:: 2020, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'docker_registry'
  action :nothing
end.run_action(:update)

include_recipe 'docker_acs::install_docker'

package %w(pass apache2-utils httpie) do
  action :install
end

directory '/opt/registry/' do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

remote_file '/usr/local/bin/docker-compose' do
  source "#{node['docker']['registry']['download_url']}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end  

link "#{node['docker']['registry']['base']['dir']}/docker-compose" do
  to '/usr/local/bin/docker-compose'
end  

%W(
  #{node['docker']['registry']['base']['dir']}
  #{node['docker']['registry']['base']['dir']}/conf
).each do |path|
  directory path do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
    recursive true
  end
end

template "#{node['docker']['registry']['base']['dir']}/docker-compose.yaml" do
  source 'docker-compose.yaml.erb'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# create ssl cert
template "#{node['docker']['registry']['cache']['dir']}/docker_ca.crt" do
  source 'docker_ca.crt.erb'
  action :create
end

template "#{node['docker']['registry']['cache']['dir']}/docker_ca.key" do
  source 'docker_ca.key.erb'
  action :create
end

ca_cert = "#{node['docker']['registry']['cache']['dir']}/docker_ca.crt"
ca_key = "#{node['docker']['registry']['cache']['dir']}/docker_ca.key"
docker_cert_path = "#{node['docker']['registry']['base']['dir']}/conf/docker.crt"
docker_cert_key = "#{node['docker']['registry']['base']['dir']}/conf/docker.key"

ssl_certificate 'docker_registry_acs' do
  namespace     node['metadata']['common']['fqdn']
  key_source    'self-signed'
  cert_source   'with_ca'
  ca_cert_path  ca_cert
  ca_key_path   ca_key
  cert_path     docker_cert_path
  key_path      docker_cert_key
end

# make trust cert
directory "#{node['docker']['registry']['sert_dir']}/#{node['metadata']['common']['fqdn']}:5000//" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

execute 'crt' do
  command <<-EOF
    cp "#{node['docker']['registry']['cache']['dir']}/docker_ca.crt" "/etc/docker/certs.d/#{node['metadata']['common']['fqdn']}:5000/ca.crt"
  EOF
end

data_interface_datics 'datics' do
  service 'docker_registry'
  action :push
end

execute 'create_eo_account' do
  sensitive true
  command <<-EOF
    htpasswd -Bbc #{node['docker']['registry']['base']['dir']}/conf/registry.htpasswd admin #{node['metadata']['docker_registry']['login_password']}
  EOF
  creates "#{node['docker']['registry']['base']['dir']}/conf/registry.htpasswd"
end

# run docker-registry
execute 'docker-compose up -d' do
  cwd "#{node['docker']['registry']['base']['dir']}"
  user 'root'
  command "./docker-compose up -d"
  action :run
end

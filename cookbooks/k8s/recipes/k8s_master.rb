#
# Cookbook:: k8s
# Recipe:: k8s master
#
# Copyright:: 2023, All Rights Reserved.

bash 'run RKE2 installer' do
  code <<-EOH
    curl -sfL https://get.rke2.io | sh
  EOH
  action :run
end

# The rke2-server service will be installed. The rke2-server service will be configured to restart after the node reboots automatically or if the process crashes or is killed.
# Additional utilities will be installed at /var/lib/rancher/rke2/bin/. They include: kubectl, crictl, and ctr. Note that these are not on your path by default.
# Two cleanup scripts, rke2-killall.sh and rke2-uninstall.sh, will be installed to the path at:
# /usr/local/bin for regular file systems
# /opt/rke2/bin for read-only and brtfs file systems

# INSTALL_RKE2_TAR_PREFIX/bin if INSTALL_RKE2_TAR_PREFIX is set
# A kubeconfig file will be written to /etc/rancher/rke2/rke2.yaml.
# A token that can be used to register other server or agent nodes will be created at /var/lib/rancher/rke2/server/node-token

service 'rke2-server' do
  supports restart: true, reload: true, status: true
  action [:enable, :start]
end

# # Add the Kubernetes APT repository
# apt_repository 'kubernetes' do
#   uri 'https://apt.kubernetes.io/'
#   keyserver 'keyserver.ubuntu.com'
#   key 'B53DC80D13EDEF05'
#   distribution 'kubernetes-xenial'
#   components ['main']
#   action :add
#   cache_rebuild true
# end

# # Install kubectl package
# apt_package 'kubectl' do
#   action :install
# end

ruby_block 'read node token from file and set it as normal attribute' do
  block do
  #   org_key = ::File.open(new_resource.org_key_path, "rt").read
  # orch_key = ::File.open(new_resource.orch_key_path, "rt").read

  # http_request 'Call orch' do
  #   action :post
  #   url node['eporch2']['api_path'] + node['eporch2']['private_metadata_url']
  #   message ({
  #     :name => node['name'],
  #     :key => Base64.encode64(org_key),
  #     :apikey => Base64.encode64(orch_key)
  #   }.map{|k,v| "#{k}=#{v}"}.join('&'))
  # end

    node.normal['k8s']['node']['token'] = File.read('/var/lib/rancher/rke2/server/node-token')
    # export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
    ENV['KUBECONFIG'] = '/etc/rancher/rke2/rke2.yaml'
  end
  action :run
  only_if { ::File.exist?("/var/lib/rancher/rke2/server/node-token") }
  # not if sended
end


# comment -- cant write databag ...

# my_data_bag_item = {
#   'id' => 'k8s_config',
#   'token' => node['k8s']['node']['token']
# }

# chef_data_bag_item 'k8s_config' do
#   data_bag 'k8s_config'
#   raw_json my_data_bag_item
#   action :create 
# end

# require 'chef'

# databag_item = Chef::DataBagItem.new
# databag_item.data_bag("k8s_config")
# databag_item.raw_data = my_data_bag_item
# databag_item.save

# execute kubectl
# export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
# /var/lib/rancher/rke2/bin/kubectl get node


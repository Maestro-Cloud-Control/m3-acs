#
# Cookbook:: k8s
# Recipe:: ceph monitor
#
# Copyright:: 2023, All Rights Reserved.

package 'ceph' do
  action :install
end

template '/etc/ceph/ceph.conf' do
  source      'ceph/ceph.conf.erb'
  owner       'root'
  group       'root'
  mode        '0755'
  action      :create
  variables(
    ceph_network_cidr: node['metadata']['ceph']['network_cidr']
    ceph_fsid:         node['metadata']['ceph']['fsid']
    ip:                node['ipaddress']
    hostname:          node['hostname']
  )
end

bash 'create ceph keyring' do
  code <<-EOH
    ceph-authtool --create-keyring /etc/ceph/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
    ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *' 
    ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r' 
    ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring 
    ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
  EOH
  action :run
end

# -> send key to orch ???

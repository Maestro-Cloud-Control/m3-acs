#
# Cookbook:: k8s
# Recipe:: ceph node
#
# Copyright:: 2023, All Rights Reserved.

package 'ceph' do
  action :install
end

[
  { 'path' => '/etc/ceph/ceph.client.admin.keyring', 'content' => node['metadata']['ceph']['client_admin_keyring'] },
  { 'path' => '/var/lib/ceph/bootstrap-osd/ceph.keyring', 'content' => node['metadata']['ceph']['keyring'] },
].each do |file|
  file file['path'] do
    content file['content']
    mode    '0755'
    owner   'ceph'
    group   'ceph'
  end
end

bash 'run RKE2 installer' do
  code <<-EOH
    chown ceph. /etc/ceph/ceph.* /var/lib/ceph/bootstrap-osd/*;
    parted --script /dev/sdb 'mklabel gpt'; \
    parted --script /dev/sdb "mkpart primary 0% 100%"; \
    ceph-volume lvm create --data /dev/sdb1
  EOH
  action :run
end

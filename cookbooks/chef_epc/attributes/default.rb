default['chef']['epc']['version'] = '15.7.0'
default['chef']['epc']['deb_package']['source'] = "https://packages.chef.io/files/stable/chef-server/#{node['chef']['epc']['version']}/ubuntu/22.04/chef-server-core_#{node['chef']['epc']['version']}-1_amd64.deb"
default['chef']['epc']['conf']['dir'] = '/root/.chef'

# default
default['chef']['epc']['org']['name'] = 'my-org'
default['chef']['epc']['validation']['key']['name'] = 'validator'
default['chef']['epc']['user']['name'] = 'admin'



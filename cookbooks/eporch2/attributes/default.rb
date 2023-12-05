default['eporch']['value_of_the_project_id_since_last_chef_client_run'] = ''

default['own']['chef']['certificates_bundle'] = ''

# unattended-upgrades
default['unattended-upgrades']['package_blacklist'] = ['chef']
default['unattended-upgrades']['admin_email'] = nil

case node['os']
when 'windows'
  default['eporch2']['config_dir'] = 'C:\\epconfig'
  default['chef_client_path'] = 'C:\\opscode\\chef\\embedded\\bin\\ruby.exe C:\\opscode\\chef\\bin\\chef-client'
  default['chef_client']['requires_local'] = ["c:/chef/start_handler.rb"]
when 'linux'
  default['eporch2']['config_dir'] = '/etc/epconfig/'
  default['chef_client_path'] = '/opt/chef/bin/chef-client'
  default['chef_client']['requires_local'] = ["/etc/chef/start_handler.rb"]
end

default['epc_out']['dummy']['dummy'] = 'dummy_str'

default['run_list']['removed_items'] = []
default['run_list']['added_items'] = []

default['chef_client']['interval'] = '360'
default['chef_client']['splay'] = '60'
default['ohai']['disabled_plugins'] = [ :Openstack ]
default['chef_client']['config']['log_level'] = 'info'
default['chef_client']['config']['start_handlers'] = [
  {"class" => "Chef::EpHandler::StartHandler", "arguments" => []}
]

default['chef_client']['logrotate']['frequency'] = 'hourly'

override['chef_client']['config']['encrypted_data_bag_secret'] = \
  (Pathname(::File.dirname(Chef::Config['config_file'])) + 'secret').to_s


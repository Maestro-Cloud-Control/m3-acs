resource_name :zabbix_client_attributes
default_action :update

property :name, String, default: ''

action :update do
  server_addr = node['metadata']['zabbix_client']['server_fqdn']
  if server_addr.nil?
    Chef::Log.warn('Zabbix server hostname is not defined')
  else
    Chef::Log.info('Zabbix server hostname: ' + server_addr)
    node.normal['zabbix-client']['zabbix-server'] = server_addr if node['zabbix-client']['zabbix-server'] != server_addr
  end
end

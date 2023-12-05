default['zabbix-client']['release'] = '5.0'
default['zabbix-client']['debian']['version'] = '5.0-1'
default['zabbix-client']['rhel']['version'] = '5.0-1'
default['zabbix-client']['win']['version'] = '4.0.15'


default['zabbix-client']['zabbix_hostname'] = node['name']
default['zabbix-client']['zabbix-server'] = 'localhost'

if node['platform'] ==  'windows'
  default['zabbix-client']['win']['service_name'] = 'Zabbix Agent'
  default['zabbix-client']['win']['home'] = "#{ENV['SYSTEMDRIVE']}\\Zabbix"
  default['zabbix-client']['win']['temp'] = "#{ENV['SYSTEMDRIVE']}\\Windows\\Temp"
  default['zabbix-client']['win']['temp_src'] = "#{ENV['SYSTEMDRIVE']}\\Windows\\Temp\\bin\\win64"

  default['zabbix-client']['win']['agent_url'] = "https://www.zabbix.com/downloads/#{node['zabbix-client']['win']['version']}/zabbix_agent-#{node['zabbix-client']['win']['version']}-win-amd64-openssl.msi"
else
  default['zabbix-client']['run_dir'] = '/var/run/zabbix'
  default['zabbix-client']['log_dir'] = '/var/log/zabbix'
  default['zabbix-client']['include_dir'] = '/etc/zabbix/zabbix_agentd.d/'

  os_version = node['platform_version'].split('.')[0]
  default['zabbix-client']['debian']['repo_package'] = "https://repo.zabbix.com/zabbix/#{node['zabbix-client']['release']}/#{node['platform']}/pool/main/z/zabbix-release/zabbix-release_#{node['zabbix-client']['debian']['version']}+#{node['lsb']['codename']}_all.deb"
  default['zabbix-client']['rhel']['repo_package'] = "https://repo.zabbix.com/zabbix/#{node['zabbix-client']['release']}/rhel/#{os_version}/x86_64/zabbix-release-#{node['zabbix-client']['rhel']['version']}.el#{os_version}.noarch.rpm"
end

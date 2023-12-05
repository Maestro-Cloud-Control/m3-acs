branch = default['zabbix']['branch'] = '6.4'
release = default['zabbix']['release'] = '6.4-1'

default['zabbix']['debian']['release_package'] = "https://repo.zabbix.com/zabbix/#{branch}/#{node['platform']}/pool/main/z/zabbix-release/zabbix-release_#{release}+#{node['lsb']['id'].downcase}#{node['lsb']['release']}_all.deb"

default['apache']['listen_ports'] = '81'

default['zabbix-server']['docroot'] = '/usr/share/zabbix'

default['zabbix-server']['apache_mpm'] = 'prefork'

default['zabbix-server']['run_dir'] = '/var/run/zabbix'
default['zabbix-server']['log_dir'] = '/var/log/zabbix-server'
default['zabbix-server']['phpconf_dir'] = '/etc/zabbix/web'
default['zabbix-server']['include_dir'] = '/etc/zabbix/zabbix_server.d/'
default['zabbix-server']['alert_dir'] = '/etc/zabbix/alert.d/'

# db attributes
default['zabbix-server']['mysql']['mysql_version'] = '8.0'
default['zabbix-server']['mysql']['dbport'] = 3306
default['zabbix-server']['mysql']['dbhost'] = '127.0.0.1'
default['zabbix-server']['mysql']['dbname'] = 'zabbix'
default['zabbix-server']['mysql']['dbuser'] = 'zabbix'
# default['zabbix-server']['mysql']['db_restored']['status'] = ''

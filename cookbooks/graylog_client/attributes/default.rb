default['graylog']['client']['graylog_server_ip_new'] = false

default['graylog']['client']['evtsys']['version'] = '4.5.1'
default['graylog']['client']['evtsys']['arch'] = node['kernel']['machine'] =~ /x86_64/ ? '64-Bit' : '32-Bit'
arche = node['graylog']['client']['evtsys']['version']
versione = node['graylog']['client']['evtsys']['arch']
default['graylog']['client']['evtsys']['pkg'] = "Evtsys_#{arche}_#{versione}.zip"

default['graylog']['client']['syslog_agent']['version'] = 'v2.3'
default['graylog']['client']['syslog_agent']['arch'] = node['kernel']['machine'] =~ /x86_64/ ? '64-Bit' : '32-Bit'
arch = node['graylog']['client']['syslog_agent']['version']
version = node['graylog']['client']['syslog_agent']['arch']
default['graylog']['client']['syslog_agent']['pkg'] = "syslog-agent_#{arch}_#{version}.zip"
default['yum']['epel']['enabled'] = true

default['graylog']['client']['download_url'] = 'https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/eventlog-to-syslog/Evtsys_4.5.1_64-Bit-LP.zip'
default['graylog']['client']['dir'] = 'c:/graylog-client'
default['graylog']['client']['dir_system32'] = 'C:/Windows/System32'

default['graylog']['conf']['proto'] = 'tcp'
# TCP - 01, UDP - 00
default['graylog']['conf']['winproto'] = '01'
# hex(202)=dec(514)
default['graylog']['conf']['port'] = '202'

if platform?('centos')
  default['epel']['version'] = node['platform_version'].to_i
end

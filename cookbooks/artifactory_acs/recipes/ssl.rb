#
# Cookbook:: artifactory_acs
# Recipe:: ssl
#
# Copyright:: 2019
#
# All Rights Reserved.

node.override['nginx_proxy']['ssl_key_dir'] = '/etc/pki/tls/private/'

fqdn = node['metadata']['common']['fqdn']

node.override['ssl_certificate']['items'] = [
  {
    'name' => fqdn,
    'common_name' => fqdn,
    'source' => 'self-signed',
  },
]

node.override['nginx_proxy']['proxies'] = {
  fqdn => {
    'port' => '8082',
    'ssl_key' => fqdn,
    'cookbook' => 'proxy',
  },
}

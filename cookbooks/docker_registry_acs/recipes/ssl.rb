#
# Cookbook:: docker_registry_acs
# Recipe:: ssl
#
# Copyright:: 2023, All Rights Reserved.

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
    'port' => '5000',
    'ssl_key' => fqdn,
    'cookbook' => 'proxy',
  },
}

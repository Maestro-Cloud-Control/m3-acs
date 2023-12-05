#
# Cookbook:: lamp
# Recipe:: ssl
#
# Copyright:: 2019, All Rights Reserved.

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
    'port' => '81',
    'ssl_key' => fqdn,
    'cookbook' => 'proxy',
    'soft_https' => true,
  },
}

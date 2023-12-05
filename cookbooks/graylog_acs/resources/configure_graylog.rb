property :retries, Integer
property :retry_delay, Integer
property :admin_password, String

action :configure do
  http_request 'syslog_tcp' do
    url 'http://127.0.0.1:9000/api/system/inputs'
    action :post
    headers(
      'AUTHORIZATION' => "Basic #{Base64.encode64("admin:#{new_resource.admin_password}")}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'X-Requested-By' => 'cli'
    )
    message ::File.read('/tmp/syslog_tcp.json')
    retries     new_resource.retries
    retry_delay new_resource.retry_delay
    sensitive   true
  end

  http_request 'syslog_upd' do
    url 'http://127.0.0.1:9000/api/system/inputs'
    action :post
    headers(
      'AUTHORIZATION' => "Basic #{Base64.encode64("admin:#{new_resource.admin_password}")}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'X-Requested-By' => 'cli'
    )
    message ::File.read('/tmp/syslog_udp.json')
    retries     new_resource.retries
    retry_delay new_resource.retry_delay
    sensitive   true
  end

  http_request 'syslog_user' do
    url 'http://127.0.0.1:9000/api/users'
    action :post
    headers(
      'AUTHORIZATION' => "Basic #{Base64.encode64("admin:#{new_resource.admin_password}")}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'X-Requested-By' => 'cli'
    )
    message ::File.read('/tmp/syslog_user.json')
    retries     new_resource.retries
    retry_delay new_resource.retry_delay
    sensitive   true
  end

  node.normal['graylod_acs']['conf_status'] = 'configured'

end


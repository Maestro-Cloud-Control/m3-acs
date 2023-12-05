#
# Cookbook:: gerrit_acs
# Recipe:: conf_revers_proxy
#
# Copyright:: 2023, All Rights Reserved.

template "/etc/nginx/sites-available/default" do
    source 'nginx.default.erb'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    notifies :restart, 'service[nginx]'
    variables(
        :port => node['gerrit']['port']
    )
end

execute 'http base auth' do
    command "htpasswd -b -c /etc/nginx/.htpasswd admin #{node['metadata']['gerrit']['login_password']}"
    sensitive true
    action  :run
end

service 'nginx' do
  action [:enable, :start]
end

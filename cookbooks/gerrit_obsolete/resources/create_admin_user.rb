#
# Cookbook::  gerrit_acs
# Resources:: configure_admin_user
#
# Copyright:: 2019, All Rights Reserved.

action_class do
  require 'net/http'
end

action :set do
  # create ssh-key pair
  ssh_keygen "#{node['gerrit']['home_dir']}/.ssh/id_rsa" do
    action :nothing
    owner 'gerrit'
    group 'gerrit'
    strength 4096
    type 'rsa'
    secure_directory true
  end.run_action(:create)

  gerrit_admin_username              = 'admin'
  gerrit_home_page                   = "http://#{node['metadata']['common']['fqdn']}:#{node['gerrit']['httpd']['listen_port']}"
  gerrit_login_page                  = "#{gerrit_home_page}/login/"
  gerrit_accounts_self_username_page = "#{gerrit_home_page}/accounts/self/username"
  gerrit_accounts_self_sshkeys_page  = "#{gerrit_home_page}/accounts/self/sshkeys"

  # set the owner of the worstation an admin' do
  resp1 = Net::HTTP.get_response(URI(gerrit_login_page))
  Chef::Log.info("Gerrit login page returned #{resp1.code}")

  account_exist = resp1.body.include? '1000000'

  resp2 = if account_exist
            Chef::Log.info('Found admin user, using it')
            Net::HTTP.get_response(URI(gerrit_login_page + '?account_id=1000000'))
          else
            Chef::Log.info('Admin user not found, creating')
            Net::HTTP.post_form(URI(gerrit_login_page), 'action' => 'create_account')
          end
  Chef::Log.info("Received #{resp2.code}")
  gaid = resp2.get_fields('set-cookie')[0].split(';')[0].split('=')[1]

  req3           = Net::HTTP::Get.new(URI(gerrit_home_page))
  req3['Cookie'] = "GerritAccount=#{gaid}"
  resp3          = Net::HTTP.start(node['metadata']['common']['fqdn'], node['gerrit']['httpd']['listen_port']) {|http| http.request(req3)}
  xsrf           = resp3.get_fields('set-cookie')[0].split(';')[0].split('=')[1]
  Chef::Log.info("Retrieving xsrf code. Received #{resp3.code}")

  unless account_exist
    req4                  = Net::HTTP::Put.new(URI(gerrit_accounts_self_username_page))
    req4['Cookie']        = "GerritAccount=#{gaid}; XSRF_TOKEN=#{xsrf}"
    req4['X-Gerrit-Auth'] = xsrf
    req4['Content-Type']  = 'application/json'
    req4.body             = '{"username":"%s"}' % gerrit_admin_username
    resp4                 = Net::HTTP.start(node['metadata']['common']['fqdn'], node['gerrit']['httpd']['listen_port']) {|http| http.request(req3)}
    Chef::Log.info("Setting root user name returned #{resp4.code}")
  end

  req5                  = Net::HTTP::Post.new(URI(gerrit_accounts_self_sshkeys_page))
  req5['Cookie']        = "GerritAccount=#{gaid}; XSRF_TOKEN=#{xsrf}"
  req5['X-Gerrit-Auth'] = xsrf
  req5['Content-Type']  = 'plain/text'
  req5.body             = ::File.read("#{node['gerrit']['home_dir']}/.ssh/id_rsa.pub")
  resp5                 = Net::HTTP.start(node['metadata']['common']['fqdn'], node['gerrit']['httpd']['listen_port']) {|http| http.request(req5)}
  Chef::Log.info("Adding ssh key returned #{resp5.code}")

  # update gerrit.config
  node.normal['gerrit']['auth']['type'] = 'LDAP'
  find_resource!(:template, 'upload gerrit.config').run_action(:create)
  find_resource!(:service, 'gerrit').run_action(:restart)

  execute 'set up machine owner as admin gerrit server' do
    command "ssh \
      -o StrictHostKeyChecking=no  \
      -o UserKnownHostsFile=/dev/null \
      -i #{node['gerrit']['home_dir']}/.ssh/id_rsa \
      -p 29418 #{gerrit_admin_username}@#{node['metadata']['common']['fqdn']} gerrit set-members \
      -a #{node['metadata']['common']['ep_ownername']} Administrators"
    action :run
  end
end

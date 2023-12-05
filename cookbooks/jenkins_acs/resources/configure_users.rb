#
# Cookbook Name:: jenkins_acs
# Resource:: configure_users
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute

unified_mode true

property :users, Array
property :flags_path, String

action :configure do
  ::Chef::Provider.send(:include, Opscode::OpenSSL::Password)

  file 'users-configured' do
    path    "#{new_resource.flags_path}/users-configured"
    action  :create
  end

  # Create user configuration script
  jenkins_user_configuration = "
    import jenkins.model.*
    import hudson.security.*

    def instance = Jenkins.getInstance()

    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    instance.setSecurityRealm(hudsonRealm)

    def strategy = new GlobalMatrixAuthorizationStrategy()
  "

  new_resource.users.each do |user|
    jenkins_user_configuration += "strategy.add(Jenkins.#{user['privileges']}, \"#{user['name']}\") \n"
    jenkins_user user['name'] do
      password    user['password']
      public_keys [ user['sshkey'] ]
      not_if      { ::File.exist?("#{node['jenkins']['master']['home']}/users/#{user['name']}/config.xml") }
      notifies    :delete, 'file[users-configured]', :immediately
    end
  end

  jenkins_user_configuration += "
    instance.setAuthorizationStrategy(strategy)
    instance.save()
  "

  jenkins_script 'Config users' do
    command jenkins_user_configuration
    action  :execute
    not_if  { ::File.exist?("#{new_resource.flags_path}/users-configured") }
  end
end

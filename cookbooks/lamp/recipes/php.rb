#
# Cookbook:: lamp
# Recipe:: php
#
# Copyright:: 2023, All Rights Reserved.

include_recipe 'php'

execute 'disable php7.4 apache mod' do
  command '/usr/sbin/a2dismod php7.4'
  action :run
end

%w(
  php-pear
  libapache2-mod-php
  php-mysql
).each do |pkg|
  package pkg do
    action   :install
    timeout  1500
    notifies :restart, "service[apache2]"
  end
end






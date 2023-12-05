property :user,        kind_of: String, name_property: true
property :password,    kind_of: String
property :vhost,       kind_of: [String, Array]
property :permissions, kind_of: String
property :tag,         kind_of: String

default_action :add

action_class do
  def whyrun_supported?
    false
  end
end

action :add do
  Chef::Application.fatal!('rabbitmq_user with action :add requires a non-nil/empty password.') if new_resource.password.nil? || new_resource.password.empty?
  new_password = new_resource.password.gsub("'", "'\\\\''")
  cmd = "rabbitmqctl add_user #{new_resource.user} '#{new_password}'"
  execute "rabbitmqctl -q add_user #{new_resource.user}" do # ~FC009
    sensitive true
    command cmd
    environment ({ 'HOME' => '/var/lib/rabbitmq' })
    Chef::Log.info "Adding RabbitMQ user '#{new_resource.user}'."
  end
end

action :set_permissions do
  perm_list = new_resource.permissions.split
  vhosts = new_resource.vhost.is_a?(Array) ? new_resource.vhost : [new_resource.vhost]
  filtered = vhosts.reject { |vhost| user_has_expected_permissions?(new_resource.user, vhost, perm_list) }
  # filter out vhosts for which the user already has the permissions we expect
  filtered.each do |vhost|
    vhostopt = "-p #{vhost}" unless vhost.nil?
    cmd = "rabbitmqctl -q set_permissions #{vhostopt} #{new_resource.user} \"#{perm_list.join('" "')}\""
    execute cmd do
      environment ({ 'HOME' => '/var/lib/rabbitmq' })
      Chef::Log.info "Setting RabbitMQ user permissions for '#{new_resource.user}' on vhost #{vhost}."
    end
  end
end

action :set_tags do
  unless user_has_tag?(new_resource.user, new_resource.tag)
    cmd = "rabbitmqctl -q set_user_tags #{new_resource.user} #{new_resource.tag}"
    execute cmd do
      environment ({ 'HOME' => '/var/lib/rabbitmq' })
      Chef::Log.info "Setting RabbitMQ user '#{new_resource.user}' tags '#{new_resource.tag}'"
    end
  end
end

def installed_rabbitmq_version
  node['packages']['rabbitmq-server']['version'][/[^-]+/]
end

def user_has_tag?(name, tag)
  cmd = if Gem::Version.new(installed_rabbitmq_version) >= Gem::Version.new('3.7.10')
          'rabbitmqctl -s list_users'
        else
          'rabbitmqctl -q list_users'
        end
  cmd = Mixlib::ShellOut.new(cmd, env: { 'HOME' => '/var/lib/rabbitmq' })
  cmd.run_command
  user_list = cmd.stdout
  tags = user_list.match(/^#{name}\s+\[(.*?)\]/)[1].split
  Chef::Log.debug "rabbitmq_user_has_tag?: #{cmd}"
  Chef::Log.debug "rabbitmq_user_has_tag?: #{cmd.stdout}"
  Chef::Log.debug "rabbitmq_user_has_tag?: #{name} has tags: #{tags}"
  if tag.nil? && tags.empty?
    true
  elsif tags.include?(tag)
    true
  else
    false
  end
rescue RuntimeError
  false
end

def user_has_expected_permissions?(name, vhost, perm_list = nil)
  vhost = '/' if vhost.nil? # rubocop:enable all
  cmd = if Gem::Version.new(installed_rabbitmq_version) >= Gem::Version.new('3.7.10')
          "rabbitmqctl -s list_user_permissions #{name} | grep \"^#{vhost}\\s\""
        else
          "rabbitmqctl -q list_user_permissions #{name} | grep \"^#{vhost}\\s\""
        end
  cmd = Mixlib::ShellOut.new(cmd, env: { 'HOME' => '/var/lib/rabbitmq' })
  cmd.run_command
  Chef::Log.debug "rabbitmq_user_has_expected_permissions?: #{cmd}"
  Chef::Log.debug "rabbitmq_user_has_expected_permissions?: #{cmd.stdout}"
  Chef::Log.debug "rabbitmq_user_has_expected_permissions?: #{cmd.exitstatus}"
  # no permissions found and none expected
  if perm_list.nil? && cmd.stdout.empty?
    Chef::Log.debug 'rabbitmq_user_has_expected_permissions?: no permissions found'
    return true
  end
  # existing match search
  if perm_list == cmd.stdout.split.drop(1)
    Chef::Log.debug 'rabbitmq_user_has_expected_permissions?: matching permissions already found'
    return true
  end
  Chef::Log.debug 'rabbitmq_user_has_expected_permissions?: permissions found but do not match'
  false
end

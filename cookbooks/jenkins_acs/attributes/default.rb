override['corretto-java']['version'] = '11'

default['jenkins']['master']['channel'] = 'stable'
default['jenkins']['master']['repository_key'] = 
    case [node['platform_family'], node['jenkins']['master']['channel']]
        when %w(debian stable)
    'https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key'
        when %w(rhel stable), %w(amazon stable)
    'https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key'
        when %w(debian current)
    'https://pkg.jenkins.io/debian/jenkins.io-2023.key'
        when %w(rhel current), %w(amazon current)
    'https://pkg.jenkins.io/redhat/jenkins.io-2023.key'
    end

default['jenkins']['executor']['protocol'] = 'http'
default['jenkins']['executor']['timeout'] = 400
default['jenkins']['login_password'] =  lazy { node['metadata']['jenkins']['login_password'] }

# default value -1 is blocked; 0 is random;
default['jenkins_acs']['cli']['sshd']['port'] = '0'

default['jenkins_acs']['jenkins_user'] = 'jenkins'
default['jenkins_acs']['jenkins_group'] = 'jenkins'

default['jenkins_acs']['default_plugins'] = [
  { 'name' => 'logstash' },
  { 'name' => 'matrix-auth' },
  { 'name' => 'matrix-project' },
  { 'name' => 'script-security' },
  { 'name' => 'ssh-credentials' },
  { 'name' => 'ssh-slaves' },
  { 'name' => 'windows-slaves' },
  { 'name' => 'workflow-api' },
  { 'name' => 'workflow-basic-steps' },
  { 'name' => 'workflow-cps' },
  { 'name' => 'workflow-durable-task-step' }, 
  { 'name' => 'workflow-job' },
  { 'name' => 'workflow-scm-step' },
  { 'name' => 'workflow-step-api' },
  { 'name' => 'workflow-support' },
  { 'name' => 'configuration-as-code' },
]


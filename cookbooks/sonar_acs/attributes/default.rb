override['corretto-java']['version'] = '11'
# override['corretto-java']['version'] = '17'

# default['sonarqube']['version'] = '7.9'
default['sonarqube']['version'] = '8.9'
# override['sonarqube']['version'] = '9.9'
# default['sonarqube']['checksum'] = 'ab6c63c961f2e45c94b11ada2e5f2ff80f2da1eab31d364ffb91029bcb84c3e8'
default['sonarqube']['checksum'] = 'bc31dcdadf85edcbde51fff9c0977412a5e87996f4f51f68a053ec7a44cdb818'
# override['sonarqube']['checksum'] = 'f5b3045ac40b99dfc2ab45c0990074f4b15e426bdb91533d77f3b94b73d3d411'

default['sonarqube']['os_kernel'] = 'linux-x86-64'

default['sonarqube']['user'] = 'sonarqube'
default['sonarqube']['group'] = 'sonarqube'

default['sonarqube']['home']['dir'] = '/opt'

default['sonarqube']['config']['dir'] = "#{node['sonarqube']['home']['dir']}/sonarqube-%{version}/conf"
default['sonarqube']['config']['file'] = 'sonar.properties'

default['sonarqube']['plugin']['dir'] = "#{node['sonarqube']['home']['dir']}/sonarqube-#{node['sonarqube']['version']}/extensions/plugins/"

default['sonarqube']['web']['host'] = '0.0.0.0'
default['sonarqube']['web']['context'] = nil
default['sonarqube']['web']['port'] = 9000
default['sonarqube']['web']['https']['port'] = -1 # Default value of -1 leaves https disabled

# sonarqube properties
default['sonarqube']['jdbc']['username'] = 'sonar'
default['sonarqube']['jdbc']['password'] = lazy { node['metadata']['sonar']['db_user_password'] }

default['sonarqube']['embeddedDatabase']['dataDir'] = nil
default['sonarqube']['embeddedDatabase']['port'] = 9092

default['sonarqube']['jdbc']['dbname'] = 'sonar'
default['sonarqube']['jdbc']['url'] = 'jdbc:postgresql://localhost/sonar'

default['sonarqube']['jdbc']['maxActive'] = 20
default['sonarqube']['jdbc']['maxIdle'] = 5
default['sonarqube']['jdbc']['minIdle'] = 2
default['sonarqube']['jdbc']['maxWait'] = 5000
default['sonarqube']['jdbc']['minEvictableIdleTimeMillis'] = 600_000
default['sonarqube']['jdbc']['timeBetweenEvictionRunsMillis'] = 30_000

default['sonarqube']['web']['host'] = '0.0.0.0'
default['sonarqube']['web']['context'] = nil
default['sonarqube']['web']['port'] = 9000
default['sonarqube']['web']['https']['port'] = -1 # Default value of -1 leaves https disabled
default['sonarqube']['web']['https']['keyAlias'] = nil
default['sonarqube']['web']['https']['keyPass'] = 'changeit'
default['sonarqube']['web']['https']['keystoreFile'] = nil
default['sonarqube']['web']['https']['keystorePass'] = nil
default['sonarqube']['web']['https']['keystoreType'] = 'JKS'
default['sonarqube']['web']['https']['keystoreProvider'] = nil
default['sonarqube']['web']['https']['truststoreFile'] = nil
default['sonarqube']['web']['https']['truststorePass'] = nil
default['sonarqube']['web']['https']['truststoreType'] = 'JKS'
default['sonarqube']['web']['https']['truststoreProvider'] = nil
default['sonarqube']['web']['https']['clientAuth'] = false
default['sonarqube']['web']['http']['maxThreads'] = 50
default['sonarqube']['web']['http']['minThreads'] = 5
default['sonarqube']['web']['http']['acceptCount'] = 25
default['sonarqube']['web']['https']['minThreads'] = 5
default['sonarqube']['web']['https']['maxThreads'] = 50
default['sonarqube']['web']['https']['acceptCount'] = 25

default['sonarqube']['web']['accessLogs']['enable'] = true
default['sonarqube']['ajp']['port'] = 9009

default['sonarqube']['updatecenter']['activate'] = true
default['sonarqube']['http']['proxyHost'] = nil
default['sonarqube']['http']['proxyPort'] = nil
default['sonarqube']['http']['auth']['ntlm']['domain'] = nil
default['sonarqube']['socksProxyHost'] = nil
default['sonarqube']['socksProxyPort'] = nil
default['sonarqube']['http']['proxyUser'] = nil
default['sonarqube']['http']['proxyPassword'] = nil
default['sonarqube']['notifications']['delay'] = 60
default['sonarqube']['log']['profilingLevel'] = 'NONE'

default['sonarqube']['rails']['dev'] = false

default['sonarqube']['extra_properties'] = [
  # 'sonar.security.realm=LDAP',
  # 'sonar.security.savePassword=false'
]

# ci/cd integration
force_override['jenkins']['executor']['cli_user'] = 'eo'
force_override['jenkins']['executor']['protocol'] = 'ssh'
name 'zabbix-client'
maintainer ''
maintainer_email ''
license 'All rights reserved'
description 'Installs/Configures zabbix-client'
long_description 'Installs/Configures zabbix-client'
version '0.4.1'

depends 'apt'
depends 'yum'
depends 'eporch2'

%w( ubuntu centos windows ).each do |os|
  supports os
end

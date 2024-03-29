name             'graylog_acs'
maintainer       ''
maintainer_email ''
license          'All rights reserved'
description      'Installs/Configures graylog2 service'
version          '0.5.0'
chef_version     '>= 13.0'

depends 'apt', '~> 7.4.0'
depends 'graylog2', '~> 3.1.2'
depends 'sc-mongodb', '~> 5.1.15'
depends 'corretto-java'
depends 'authbind', '~> 0.1.10'

supports 'ubuntu'

name             'jenkins_acs'
maintainer       ''
maintainer_email ''
license          'All rights reserved'
description      'Installs/Configures jenkins'
version          '0.8.0'

depends  'runit', '~> 5.1.6'
depends  'corretto-java'
depends  'jenkins', '~> 9.5.15'
depends  'openssl', '~> 8.5.5'
depends  'data_interface'
depends  'ssh_authorized_keys', '~> 1.0.0'

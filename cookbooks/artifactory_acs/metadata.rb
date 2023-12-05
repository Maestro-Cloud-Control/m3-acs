name             'artifactory_acs'
maintainer       ''
maintainer_email ''
license          'All rights reserved'
description      'Installs/Configures Artifactory as a service'
long_description 'Installs/Configures Artifactory as a service'
version          '0.5.2'
chef_version     '>= 13.0'

depends          'corretto-java'
# depends          'selinux', '~> 5.0.0'
depends          'selinux_policy', '~> 2.4.3'

supports         'centos'

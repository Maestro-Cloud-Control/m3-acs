name 'eporch2'
maintainer ''
maintainer_email ''
license 'All Rights Reserved'
description 'Installs/Configures eporch2'
long_description 'Installs/Configures eporch2'
version '0.20.2'
chef_version '>= 13.0'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/eporch2/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/eporch2'

depends 'unattended-upgrades', '~> 0.1.2'
depends 'chef-client', '~> 11.5.0'

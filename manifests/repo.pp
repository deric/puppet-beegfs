# Class: beegfs::repo
#
# This module manages beegfs repository installation
#
#
# This class file is not called directly
class beegfs::repo (
  Beegfs::Release       $release,
  Boolean               $manage_repo    = $beegfs::manage_repo,
  Beegfs::PackageSource $package_source = $beegfs::package_source,
) inherits beegfs {
  anchor { 'beegfs::repo': }

  case $facts['os']['family'] {
    'Debian': {
      class { 'beegfs::repo::debian':
        release => $release,
        before  => Anchor['beegfs::repo'],
      }
    }
    'RedHat': {
      class { 'beegfs::repo::redhat':
        before  => Anchor['beegfs::repo'],
      }
    }
    default: {
      fail("Module '${module_name}' is not supported on OS: '${facts['os']['name']}', family: '${facts['os']['family']}'")
    }
  }
}

# == Class beegfs::install
#
# This class is called from beegfs for install.
#
class beegfs::install(
  Boolean               $manage_repo    = $beegfs::manage_repo,
  Beegfs::PackageSource $package_source = $beegfs::package_source,
  String                $package_ensure = $beegfs::package_ensure,
  Beegfs::LogDir        $log_dir        = $beegfs::log_dir,
  String                $user           = $beegfs::user,
  String                $group          = $beegfs::group,
  Beegfs::Release       $release        = $beegfs::release,
) {

  class {'beegfs::repo':
    manage_repo    => $manage_repo,
    package_source => $package_source,
    release        => $release,
  }

  anchor { 'beegfs::user' : }

  user { 'beegfs':
    ensure => present,
    before => Anchor['beegfs::user'],
  }

  group { 'beegfs':
    ensure => present,
    before => Anchor['beegfs::user'],
  }

  # make sure log directory exists
  ensure_resource('file', $log_dir, {
    'ensure' => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
    require => Anchor['beegfs::user'],
  })

  package { 'beegfs-utils':
    ensure  => $package_ensure,
    require => [Anchor['beegfs::repo']],
  }

}

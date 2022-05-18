# Class: beegfs::repo::redhat

class beegfs::repo::redhat (
  Boolean         $manage_repo    = true,
  Enum['beegfs']  $package_source = $beegfs::package_source,
                  $package_ensure = $beegfs::package_ensure,
  Beegfs::Release $release        = $beegfs::release,
) {

  $_os_release = $facts.dig('os', 'release', 'major')

  # If using version 7.1 the release folder has an underscore instead of a period
  $_release = if $release == '7.1' {
    $release.regsubst('\.', '_')
  } else {
    $release
  }

  $_gpg_key = if $release > '7.2.5' {
    'GPG-KEY-beegfs'
  } else {
    'RPM-GPG-KEY-beegfs'
  }

  if $manage_repo {
    case $package_source {
      'beegfs': {
        yumrepo { "beegfs_rhel${_os_release}":
          ensure   => 'present',
          descr    => "BeeGFS ${release} (rhel${_os_release})",
          baseurl  => "https://www.beegfs.io/release/beegfs_${_release}/dists/rhel${_os_release}",
          gpgkey   => "https://www.beegfs.io/release/beegfs_${_release}/gpg/RPM-GPG-KEY-beegfs",
          enabled  => '1',
          gpgcheck => '1',
        }
      }
      default: {
        fail("Unknown package source '${package_source}'")
      }
    }
  }
}

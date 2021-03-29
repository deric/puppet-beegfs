# frozen_string_literal: true

require 'spec_helper'
# test client installation on Debian systems

describe 'beegfs::client' do
  let(:facts) do
    {
      # still old fact is needed due to this
      # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
      osfamily: 'Debian',
      os: {
        family: 'Debian',
        name: 'Debian',
        architecture: 'amd64',
        distro: { codename: 'stretch' },
        release: { major: '9', minor: '9', full: '9.9' },
      },
      puppetversion: Puppet.version,
    }
  end

  let(:user) { 'beegfs' }
  let(:group) { 'beegfs' }

  context 'install apt repository and all required packages' do
    let(:release) { '7.1' }
    let(:params) do
      {
        user: user,
        group: group,
      }
    end

    let :pre_condition do
      "class {'beegfs':
         release => '#{release}',
       }"
    end

    it {
      is_expected.to contain_apt__source('beegfs').with(
        'location' => 'http://www.beegfs.io/release/beegfs_7_1',
        'repos'    => 'non-free',
        'release'  => 'stretch',
        'key'      => { 'id' => '055D000F1A9A092763B1F0DD14E8E08064497785', 'source' => 'http://www.beegfs.com/release/latest-stable/gpg/DEB-GPG-KEY-beegfs' },
        'include'  => { 'src' => false, 'deb' => true },
      )
    }

    it do
      is_expected.to contain_package('beegfs-client')
        .with(
          'ensure' => 'present',
        )
    end
    it do
      is_expected.to contain_package('linux-headers-amd64')
        .with(
          'ensure' => 'present',
        )
    end
    it do
      is_expected.to contain_package('beegfs-helperd')
        .with(
          'ensure' => 'present',
        )
    end
  end

  context 'Ubuntu 18.04' do
    let(:release) { '7.1' }
    let(:facts) do
      {
        # still old fact is needed due to this
        # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
        osfamily: 'Debian',
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          architecture: 'amd64',
          distro: { codename: 'bionic' },
          release: { major: '18', minor: '04', full: '18.04' },
        },
        puppetversion: Puppet.version,
      }
    end

    let :pre_condition do
      "class {'beegfs':
         release => '#{release}',
       }"
    end

    it {
      is_expected.to contain_apt__source('beegfs').with(
        'location' => 'http://www.beegfs.io/release/beegfs_7_1',
        'repos'    => 'non-free',
        'release'  => 'buster', # TODO: 7.1.x has no buster release
        'key'      => { 'id' => '055D000F1A9A092763B1F0DD14E8E08064497785', 'source' => 'http://www.beegfs.com/release/latest-stable/gpg/DEB-GPG-KEY-beegfs' },
        'include'  => { 'src' => false, 'deb' => true },
      )
    }
  end

  context 'install 7.2 release' do
    let(:release) { '7.2' }

    let :pre_condition do
      "class {'beegfs':
         release => '#{release}',
       }"
    end

    it {
      is_expected.to contain_apt__source('beegfs').with(
        'location' => 'http://www.beegfs.io/release/beegfs_7.2',
        'repos'    => 'non-free',
        'release'  => 'stretch',
        'key'      => { 'id' => '055D000F1A9A092763B1F0DD14E8E08064497785', 'source' => 'http://www.beegfs.com/release/latest-stable/gpg/DEB-GPG-KEY-beegfs' },
        'include'  => { 'src' => false, 'deb' => true },
      )
    }
  end

  context 'install 7.1.5 release' do
    let(:release) { '7.1.5' }

    let :pre_condition do
      "class {'beegfs':
         release => '#{release}',
       }"
    end

    it {
      is_expected.to contain_apt__source('beegfs').with(
        'location' => 'http://www.beegfs.io/release/beegfs_7.1.5',
        'repos'    => 'non-free',
        'release'  => 'stretch',
        'key'      => { 'id' => '055D000F1A9A092763B1F0DD14E8E08064497785', 'source' => 'http://www.beegfs.com/release/latest-stable/gpg/DEB-GPG-KEY-beegfs' },
        'include'  => { 'src' => false, 'deb' => true },
      )
    }
  end
end

# frozen_string_literal: true

require 'spec_helper'
# test client installation on Debian systems

describe 'beegfs::client' do
  let(:facts) do
    {
      # still old fact is needed due to this
      # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
      osfamily: 'RedHat',
      os: {
        family: 'RedHat',
        name: 'RedHat',
        architecture: 'amd64',
        release: { major: '7', minor: '0', full: '7.0' },
      },
      puppetversion: Puppet.version,
    }
  end

  let(:user) { 'beegfs' }
  let(:group) { 'beegfs' }

  context 'install 7.1 release yum repo and all required packages' do
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
      is_expected.to contain_yumrepo('beegfs_rhel7').with(
        'enabled' => '1',
        'baseurl' => 'https://www.beegfs.io/release/beegfs_7_1/dists/rhel7',
        'gpgkey'  => 'https://www.beegfs.io/release/beegfs_7_1/gpg/RPM-GPG-KEY-beegfs',
      )
    }

    it do
      is_expected.to contain_package('beegfs-client')
        .with(
          'ensure' => 'present',
        )
    end

    it do
      is_expected.to contain_package('kernel-devel').with_ensure(%r{present|installed})
    end

    it do
      is_expected.to contain_package('beegfs-helperd')
        .with(
          'ensure' => 'present',
        )
    end
  end

 context 'install 7.2.6 release yum repo and all required packages' do
    let(:release) { '7.2.6' }
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
      is_expected.to contain_yumrepo('beegfs_rhel7').with(
        'enabled' => '1',
        'baseurl' => 'https://www.beegfs.io/release/beegfs_7.2.6/dists/rhel7',
        'gpgkey'  => 'https://www.beegfs.io/release/beegfs_7.2.6/gpg/GPG-KEY-beegfs',
      )
    }

    it do
      is_expected.to contain_package('beegfs-client')
        .with(
          'ensure' => 'present',
        )
    end

    it do
      is_expected.to contain_package('kernel-devel').with_ensure(%r{present|installed})
    end

    it do
      is_expected.to contain_package('beegfs-helperd')
        .with(
          'ensure' => 'present',
        )
    end
  end

  context 'install 7.2 release yum repo and all required packages' do
    let(:release) { '7.2' }
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
      is_expected.to contain_yumrepo('beegfs_rhel7').with(
        'enabled' => '1',
        'baseurl' => 'https://www.beegfs.io/release/beegfs_7.2/dists/rhel7',
      )
    }

    it do
      is_expected.to contain_package('beegfs-client')
        .with(
          'ensure' => 'present',
        )
    end

    it {
      is_expected.to contain_package('kernel-devel').with_ensure(%r{present|installed})
    }

    it do
      is_expected.to contain_package('beegfs-helperd')
        .with(
          'ensure' => 'present',
        )
    end
  end
end

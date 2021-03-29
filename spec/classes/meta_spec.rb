# frozen_string_literal: true

require 'spec_helper'

describe 'beegfs::meta' do
  let(:facts) do
    {
      # still old fact is needed due to this
      # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
      osfamily: 'Debian',
      os: {
        family: 'Debian',
        name: 'Debian',
        architecture: 'amd64',
        distro: { codename: 'jessie' },
        release: { major: '7', minor: '1', full: '7.1' },
      },
      puppetversion: Puppet.version,
    }
  end

  let(:user) { 'beegfs' }
  let(:group) { 'beegfs' }

  let(:params) do
    {
      user: user,
      group: group,
    }
  end

  it { is_expected.to contain_class('beegfs::meta') }
  it { is_expected.to contain_class('beegfs::install') }

  shared_examples 'debian-meta' do |os, codename|
    let(:facts) do
      {
        # still old fact is needed due to this
        # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
        osfamily: 'Debian',
        os: {
          family: 'Debian',
          name: os,
          architecture: 'amd64',
          distro: { codename: codename },
          release: { major: '7', minor: '1', full: '7.1' },
        },
        puppetversion: Puppet.version,
      }
    end
    let :pre_condition do
      "class {'beegfs':
         release => '6',
       }"
    end

    it { is_expected.to contain_package('beegfs-meta') }
    it { is_expected.to contain_package('beegfs-utils') }

    it { is_expected.to contain_class('beegfs::repo::debian') }

    it do
      is_expected.to contain_service('beegfs-meta').with(
        ensure: 'running',
        enable: true,
      )
    end

    it do
      is_expected.to contain_file('/etc/beegfs/beegfs-meta.conf')
        .with(
          'ensure'  => 'present',
          'owner'   => user,
          'group'   => group,
          'mode'    => '0644',
        )
    end
  end

  context 'on debian-like system' do
    let(:user) { 'beegfs' }
    let(:group) { 'beegfs' }

    it_behaves_like 'debian-meta', 'Debian', 'wheezy'
    it_behaves_like 'debian-meta', 'Ubuntu', 'precise'
  end

  shared_examples 'beegfs-version' do |release|
    let :pre_condition do
      "class {'beegfs':
         release => '#{release}',
       }"
    end

    context 'allow changing parameters' do
      let(:params) do
        {
          mgmtd_host: '192.168.1.1',
        }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-meta.conf',
        ).with_content(%r{sysMgmtdHost(\s+)=(\s+)192.168.1.1})
      end
    end

    context 'with given version' do
      let(:facts) do
        {
          # still old fact is needed due to this
          # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
          osfamily: 'Debian',
          os: {
            family: 'Debian',
            name: 'Debian',
            architecture: 'amd64',
            distro: { codename: 'wheezy' },
            release: { major: '7', minor: '1', full: '7.1' },
          },
          puppetversion: Puppet.version,
        }
      end
      let(:version) { '2015.03.r8.debian7' }
      let(:params) do
        {
          package_ensure: version,
        }
      end

      it do
        is_expected.to contain_package('beegfs-meta')
          .with(
            'ensure' => version,
          )
      end
    end

    it do
      is_expected.to contain_file('/etc/beegfs/interfaces.meta')
        .with(
          'ensure' => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0644',
        ).with_content(%r{eth0})
    end

    context 'interfaces file' do
      let(:params) do
        {
          interfaces: ['eth0', 'ib0'],
          interfaces_file: '/etc/beegfs/meta.itf',
          user: user,
          group: group,
        }
      end

      it do
        is_expected.to contain_file('/etc/beegfs/meta.itf')
          .with(
            'ensure'  => 'present',
            'owner'   => user,
            'group'   => group,
            'mode'    => '0644',
          ).with_content(%r{ib0})
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-meta.conf',
        ).with_content(%r{connInterfacesFile(\s+)=(\s+)/etc/beegfs/meta.itf})
      end
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-meta.conf',
      ).with_content(%r{logLevel(\s+)=(\s+)3})
    end

    context 'changing log level' do
      let(:params) do
        {
          log_level: 5,
        }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-meta.conf',
        ).with_content(%r{logLevel(\s+)=(\s+)5})
      end
    end

    context 'hiera should override defaults' do
      let(:params) do
        {
          mgmtd_host: '192.168.1.1',
        }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-meta.conf',
        ).with_content(%r{sysMgmtdHost(\s+)=(\s+)192.168.1.1})
      end
    end

    context 'disable first run init' do
      let(:params) do
        {
          allow_first_run_init: false,
        }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-meta.conf',
        ).with_content(%r{storeAllowFirstRunInit(\s+)=(\s+)false})
      end
    end
  end

  context 'with beegfs' do
    it_behaves_like 'beegfs-version', '2015.03'
    it_behaves_like 'beegfs-version', '6'
  end

  context 'beegfs 6 uses different apt source naming' do
    let :pre_condition do
      'class {"beegfs":
         release => "6",
       }'
    end

    it { is_expected.to contain_package('beegfs-meta') }

    it {
      is_expected.to contain_apt__source('beegfs').with(
        'location' => 'http://www.beegfs.io/release/beegfs_6',
        'repos'    => 'non-free',
        'release'  => 'deb7',
        'key'      => { 'id' => '055D000F1A9A092763B1F0DD14E8E08064497785', 'source' => 'http://www.beegfs.com/release/latest-stable/gpg/DEB-GPG-KEY-beegfs' },
        'include'  => { 'src' => false, 'deb' => true },
      )
    }
  end
end

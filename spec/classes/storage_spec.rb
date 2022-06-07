# frozen_string_literal: true

require 'spec_helper'

describe 'beegfs::storage' do
  let(:hiera_data) { { 'beegfs::mgmtd_host' => 'foo.bar' } }

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
      'user' => user,
    'group' => group,
    }
  end

  let :pre_condition do
    'class {"beegfs":
       release => "6",
     }'
  end

  it { is_expected.to contain_class('beegfs::storage') }

  shared_examples 'debian-storage' do |os, codename|
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

    it { is_expected.to contain_package('beegfs-utils') }
    it do
      is_expected.to contain_service('beegfs-storage').with(
        ensure: 'running',
        enable: true,
      )
    end

    it do
      is_expected.to contain_file('/etc/beegfs/beegfs-storage.conf')
        .with(
          'ensure'  => 'file',
          'owner'   => user,
          'group'   => group,
          'mode'    => '0644',
        )
    end

    it do
      is_expected.to contain_file('/srv/beefgs/storage')
        .with(
          'ensure'  => 'directory',
        'owner'   => user,
        'group'   => group,
        )
    end

    it do
      is_expected.to contain_service('beegfs-storage').with(
        ensure: 'running',
        enable: true,
      )
    end
  end

  context 'on debian-like system' do
    let(:user) { 'beegfs' }
    let(:group) { 'beegfs' }

    let(:params) do
      {
        'user'  => user,
        'group' => group,
        :storage_directory => ['/srv/beefgs/storage'],
      }
    end

    it_behaves_like 'debian-storage', 'Debian', 'wheezy'
    it_behaves_like 'debian-storage', 'Ubuntu', 'precise'
  end

  shared_examples 'beegfs-version' do |release|
    let(:user) { 'beegfs' }
    let(:group) { 'beegfs' }

    let(:params) do
      {
        'user'  => user,
        'group' => group,
        :storage_directory => ['/srv/beefgs/storage'],
      }
    end

    let :pre_condition do
      "class {'beegfs':
         release => '#{release}',
       }"
    end

    context 'with given version' do
      let(:version) { '2012.10.r8.debian7' }
      let(:params) do
        {
          package_ensure: version,
        }
      end

      it do
        is_expected.to contain_package('beegfs-storage')
          .with(
            'ensure' => version,
          )
      end
    end

    it do
      is_expected.to contain_file('/etc/beegfs/interfaces.storage')
        .with(
          'ensure'  => 'file',
          'owner'   => user,
          'group'   => group,
          'mode'    => '0644',
        ).with_content(%r{eth0})
    end

    context 'interfaces file' do
      let(:params) do
        {
          interfaces: ['eth0', 'ib0'],
          interfaces_file: '/etc/beegfs/store.itf',
          user: user,
          group: group,
        }
      end

      it do
        is_expected.to contain_file('/etc/beegfs/store.itf')
          .with(
            'ensure'  => 'file',
        'owner'   => user,
        'group'   => group,
        'mode'    => '0644',
          ).with_content(%r{ib0})
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-storage.conf',
        ).with_content(%r{connInterfacesFile(\s+)=(\s+)/etc/beegfs/store.itf})
      end
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-storage.conf',
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
          '/etc/beegfs/beegfs-storage.conf',
        ).with_content(%r{logLevel(\s+)=(\s+)5})
      end
    end

    context 'set mgmtd host' do
      let(:params) do
        {
          mgmtd_host: 'mgmtd.beegfs.com',
        }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-storage.conf',
        ).with_content(%r{sysMgmtdHost(\s+)=(\s+)mgmtd.beegfs.com})
      end
    end

    context 'set mgmtd tcp port' do
      let(:params) do
        {
          mgmtd_tcp_port: 9009,
        }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-storage.conf',
        ).with_content(%r{connMgmtdPortTCP(\s+)=(\s+)9009})
      end
    end

    context 'pass storage directory as an array' do
      let(:params) do
        {
          storage_directory: ['/var/storage1', '/var/storage2'],
          user: user,
          group: group,
        }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-storage.conf',
        ).with_content(%r{storeStorageDirectory(\s+)=(\s+)/var/storage1,/var/storage2})
      end

      it do
        is_expected.to contain_file('/var/storage1')
          .with(
            'ensure'  => 'directory',
            'owner'   => user,
            'group'   => group,
          )
      end

      it do
        is_expected.to contain_file('/var/storage2')
          .with(
            'ensure'  => 'directory',
            'owner'   => user,
            'group'   => group,
          )
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
          '/etc/beegfs/beegfs-storage.conf',
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

    it { is_expected.to contain_package('beegfs-storage') }

    it {
      is_expected.to contain_apt__source('beegfs').with(
        'location' => 'http://www.beegfs.io/release/beegfs_6',
        'repos'    => 'non-free',
        'release'  => 'deb7',
        'key'      => { 'id' => '055D000F1A9A092763B1F0DD14E8E08064497785', 'source' => 'http://www.beegfs.com/release/beegfs_6/gpg/DEB-GPG-KEY-beegfs' },
        'include'  => { 'src' => false, 'deb' => true },
      )
    }
  end
end

# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'beegfs meta' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-PUPPET
      class { '::beegfs':
        release           => '7.1',
        allow_new_servers => true,
      }
      class { 'beegfs::mgmtd': }
      -> class { '::beegfs::meta':
        mgmtd_host => '127.0.0.1'
      }
      PUPPET

      # Run it twice and test for idempotency
      expect(apply_manifest(pp,
                            :catch_failures => false,
                            :debug => true).exit_code).to be_zero
      #apply_manifest(pp, :catch_changes  => true)
    end

    describe package('beegfs-mgmtd') do
      it { is_expected.to be_installed }
    end

    describe service('beegfs-mgmtd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end


    describe package('beegfs-meta') do
    #  it { is_expected.to be_installed }
    end

    describe service('beegfs-meta') do
     # it { is_expected.to be_enabled }
     # it { is_expected.to be_running }
    end

    describe user('beegfs') do
      it { is_expected.to exist }
    end

    describe group('beegfs') do
      it { is_expected.to exist }
    end
  end
end

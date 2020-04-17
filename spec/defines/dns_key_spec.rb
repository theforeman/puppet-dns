require 'spec_helper'

describe 'dns::key' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'foreman_key' }
      let(:pre_condition) { 'include dns' }
      let(:etc_named_directory) do
        case facts[:os]['family']
        when 'Debian'
          '/etc/bind'
        when 'FreeBSD'
          '/usr/local/etc/namedb'
        when 'RedHat'
          '/etc'
        when 'Archlinux'
          '/etc'
        end
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_exec('create-foreman_key.key').with_creates("#{etc_named_directory}/foreman_key.key") }
      it { is_expected.to contain_file("#{etc_named_directory}/foreman_key.key").that_requires('Exec[create-foreman_key.key]') }

      context 'secret set' do
        let(:params) do
          {
            :secret => 'top_secret',
          }
        end

        it 'should contain a file with the secret in it' do
          verify_exact_contents(catalogue, "#{etc_named_directory}/foreman_key.key", [
            'key "foreman_key" {',
            '    algorithm hmac-md5;',
            '    secret "top_secret";',
            '};',
          ])
        end

        it do
          is_expected.to contain_concat__fragment('named.conf+20-key-foreman_key.dns')
            .with_content("include \"#{etc_named_directory}/foreman_key.key\";\n")
        end
      end
    end
  end
end

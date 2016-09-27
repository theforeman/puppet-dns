require 'spec_helper'

describe 'dns' do

  describe 'on RedHat with no custom parameters' do

    let(:facts) do
      {
         :clientcert     => 'puppetmaster.example.com',
         :concat_basedir => '/doesnotexist',
         :fqdn           => 'puppetmaster.example.com',
         :osfamily       => 'RedHat',
      }
    end

    describe 'with no custom parameters' do
      it { should contain_class('dns::install') }
      it { should contain_class('dns::config') }
      it { should contain_class('dns::service') }

      it { should contain_package('bind').with_ensure('present') }

      it { should contain_concat('/etc/named/options.conf') }
      it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'directory "/var/named";',
          'recursion yes;',
          'allow-query { any; };',
          'dnssec-enable yes;',
          'dnssec-validation yes;',
          'empty-zones-enable yes;',
          'listen-on-v6 { any; };',
          'allow-recursion { localnets; localhost; };'
      ])}

      it { should contain_concat('/etc/named.conf') }
      it { verify_concat_fragment_exact_contents(catalogue, 'named.conf+10-main.dns', [
          '// named.conf',
          'include "/etc/rndc.key";',
          'controls  {',
          '        inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; };',
          '};',
          'options  {',
          '        include "/etc/named/options.conf";',
          '};',
          'include "/etc/named.rfc1912.zones";',
          '// Public view read by Server Admin',
          'include "/etc/named/zones.conf";'
      ])}

      it { should contain_file('/var/named/dynamic').with_ensure('directory') }
      it { should contain_exec('create-rndc.key').
                  with_command("/usr/sbin/rndc-confgen -r /dev/urandom -a -c /etc/rndc.key") }

      it { should contain_service('named').with_ensure('running').with_enable(true) }
    end

    describe 'with ipv6 disabled' do
      let(:params) { {:listen_on_v6 => 'none'} }
      it { should contain_concat('/etc/named/options.conf') }
      it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'listen-on-v6 { none; };',
      ])}
    end
    describe 'with empty zones disabled' do
      let(:params) { {:empty_zones_enable => 'no'} }
      it { should contain_concat('/etc/named/options.conf') }
      it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'empty-zones-enable no;',
      ])}
    end

    describe 'with dns_notify disabled' do
      let(:params) { {:dns_notify => 'no' } }
      it { should contain_concat('/etc/named/options.conf') }
      it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'notify no;',
      ])}
    end

    describe 'with forward only' do
      let(:params) { {:forward => 'only'} }
      it { should contain_concat('/etc/named/options.conf') }
      it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'forward only;',
      ])}
    end

    describe 'with undef forward' do
      let(:params) { {:forward => :undef} }
      it { should contain_concat('/etc/named/options.conf') }
      it { should contain_concat_fragment('options.conf+10-main.dns').without_content('/forward ;/') }
    end

    describe 'with false listen_on_v6' do
      let(:params) { {:listen_on_v6 => false} }
      it { should contain_concat('/etc/named/options.conf') }
      it { should contain_concat_fragment('options.conf+10-main.dns').without_content('/listen_on_v6/') }
    end

    describe 'with service_ensure stopped' do
      let(:params) { {:service_ensure => 'stopped'} }
      it { should contain_service('named').with_ensure('stopped').with_enable(true) }
    end

    describe 'with service_enable false' do
      let(:params) { {:service_enable => false} }
      it { should contain_service('named').with_ensure('running').with_enable(false) }
    end

    describe 'with acls set' do
      let(:params) { {:acls => { 'trusted_nets' => [ '127.0.0.1/24', '127.0.1.0/24' ] } } }
      it { verify_concat_fragment_exact_contents(catalogue, 'named.conf+10-main.dns', [
          '// named.conf',
          'include "/etc/rndc.key";',
          'controls  {',
          '        inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; };',
          '};',
          'options  {',
          '        include "/etc/named/options.conf";',
          '};',
          'include "/etc/named.rfc1912.zones";',
          'acl "trusted_nets"  {',
          '        127.0.0.1/24;',
          '        127.0.1.0/24;',
          '};',
          '// Public view read by Server Admin',
          'include "/etc/named/zones.conf";'
      ])}
    end

    describe 'with additional options' do
      let(:params) { { :additional_options => { 'max-cache-ttl' => 3600, 'max-ncache-ttl' => 3600 } } }
      it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'directory "/var/named";',
          'recursion yes;',
          'allow-query { any; };',
          'dnssec-enable yes;',
          'dnssec-validation yes;',
          'empty-zones-enable yes;',
          'listen-on-v6 { any; };',
          'allow-recursion { localnets; localhost; };',
          'max-cache-ttl 3600;',
          'max-ncache-ttl 3600;'
      ])}
    end
  end

  describe 'on FreeBSD with no custom parameters' do

    let(:facts) do
      {
         :clientcert => 'puppetmaster.example.com',
         :concat_basedir => '/doesnotexist',
         :fqdn => 'puppetmaster.example.com',
         :osfamily => 'FreeBSD',
      }
    end

    describe 'with no custom parameters' do
      it { should contain_class('dns::install') }
      it { should contain_class('dns::config') }
      it { should contain_class('dns::service') }

      it { should contain_package('bind910').with_ensure('present') }

      it { should contain_concat('/usr/local/etc/namedb/options.conf') }
      it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
           'recursion yes;',
           'allow-query { any; };',
           'dnssec-enable yes;',
           'dnssec-validation yes;',
           'empty-zones-enable yes;',
           'listen-on-v6 { any; };',
           'allow-recursion { localnets; localhost; };'
      ])}

      it { should contain_concat('/usr/local/etc/namedb/named.conf') }
      it { verify_concat_fragment_exact_contents(catalogue, 'named.conf+10-main.dns', [
          '// named.conf',
          'include "/usr/local/etc/namedb/rndc.key";',
          'controls  {',
          '        inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; };',
          '};',
          'options  {',
          '        include "/usr/local/etc/namedb/options.conf";',
          '};',
          '// Public view read by Server Admin',
          'include "/usr/local/etc/namedb/zones.conf";'
      ])}

      it { should contain_file('/usr/local/etc/namedb/dynamic').with_ensure('directory') }
      it { should contain_exec('create-rndc.key').
                  with_command("/usr/local/sbin/rndc-confgen -r /dev/urandom -a -c /usr/local/etc/namedb/rndc.key") }

      it { should contain_service('named').with_ensure('running').with_enable(true) }
    end

    describe 'with service_ensure stopped' do
      let(:params) { {:service_ensure => 'stopped'} }
      it { should contain_service('named').with_ensure('stopped').with_enable(true) }
    end

    describe 'with service_enable false' do
      let(:params) { {:service_enable => false} }
      it { should contain_service('named').with_ensure('running').with_enable(false) }
    end
  end
end

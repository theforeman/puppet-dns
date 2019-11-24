require 'spec_helper'

describe 'dns' do

  describe 'on RedHat with no custom parameters' do

    let(:facts) do
      {
         :clientcert     => 'puppetmaster.example.com',
         :fqdn           => 'puppetmaster.example.com',
         :osfamily       => 'RedHat',
         :ipaddress      => '192.0.2.1',
      }
    end

    describe 'with no custom parameters' do
      it { should contain_class('dns::install') }
      it { should contain_class('dns::config') }
      it { should contain_class('dns::service') }

      it { should contain_package('bind').with_ensure('present') }
      it { should contain_group('named') }

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

      it { should contain_concat('/etc/named/zones.conf').with_validate_cmd('/usr/sbin/named-checkconf %') }
      it { should contain_concat('/etc/named.conf').with_validate_cmd('/usr/sbin/named-checkconf %') }
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

      sysconfig_named_content = <<-SYSCONFIG
# This file is managed by Puppet.
#
# BIND named process options
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# OPTIONS="whatever"     --  These additional options will be passed to named
#                            at startup. Don't add -t here, enable proper
#                            -chroot.service unit file.
#                            Use of parameter -c is not supported here. Extend
#                            systemd named*.service instead. For more
#                            information please read the following KB article:
#                            https://access.redhat.com/articles/2986001
#
# DISABLE_ZONE_CHECKING  --  By default, service file calls named-checkzone
#                            utility for every zone to ensure all zones are
#                            valid before named starts. If you set this option
#                            to 'yes' then service file doesn't perform those
#                            checks.
      SYSCONFIG

      it {
        should contain_file('/etc/sysconfig/named').with(
          owner: 'root',
          group: 'root',
          mode: '0644',
          content: sysconfig_named_content
        )
      }

      it { should contain_service('named').with_ensure('running').with_enable(true).with_restart(nil) }
    end

    describe 'with unmanaged localzonepath' do

      let(:params) do {
          :localzonepath => 'unmanaged',
      } end

      it { verify_concat_fragment_exact_contents(catalogue, 'named.conf+10-main.dns', [
          '// named.conf',
          'include "/etc/rndc.key";',
          'controls  {',
          '        inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; };',
          '};',
          'options  {',
          '        include "/etc/named/options.conf";',
          '};',
          '// Public view read by Server Admin',
          'include "/etc/named/zones.conf";'
      ])}
    end


    describe 'with additional_directives' do
      let(:params) { {:additional_directives => [
        [
         'logging {',
         '  channel string {',
         '    print-severity boolean;',
         '    print-category boolean;',
         '  };',
         '};',
        ].join("\n"),
        [
         'lwres {',
         '  listen-on [ port integer ] {',
         '    ( ipv4_address | ipv6_address ) [ port integer ];',
         '  };',
         '  view string optional_class;',
         '  search { string; ... };',
         '  ndots integer;',
         '};',
        ].join("\n"),
      ]} }

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
          '// additional directives',
          'logging {',
          '  channel string {',
          '    print-severity boolean;',
          '    print-category boolean;',
          '  };',
          '};',
          'lwres {',
          '  listen-on [ port integer ] {',
          '    ( ipv4_address | ipv6_address ) [ port integer ];',
          '  };',
          '  view string optional_class;',
          '  search { string; ... };',
          '  ndots integer;',
          '};',
          '// Public view read by Server Admin',
          'include "/etc/named/zones.conf";'
      ])}
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

    describe 'with service_restart_command set to "/usr/sbin/service bind9 reload' do
      let(:params) { {:service_restart_command => '/usr/sbin/service bind9 reload'} }
      it {
        should contain_service('named')
          .with_ensure('running')
          .with_enable(true)
          .with_restart('/usr/sbin/service bind9 reload')
      }
    end

    describe 'with group_manage false' do
      let(:params) { {:group_manage => false} }
      it { should_not contain_group('named') }
    end

    describe 'with manage_service true' do
      let(:params) { {:manage_service => true} }
      it { should contain_service('named') }
    end

    describe 'with manage_service false' do
      let(:params) { {:manage_service => false} }
      it { should_not contain_service('named') }
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

    describe 'with zones' do
      let :params do
        {
          :zones => {
            'example.com' => {},
          },
        }
      end

      it { should compile.with_all_deps }
      it { should contain_dns__zone('example.com') }
    end

    describe 'with keys' do
      let :params do
        {
          :keys => {
            'dns-key' => {},
          },
        }
      end

      it { should compile.with_all_deps }
      it { should contain_dns__key('dns-key') }
    end

    describe 'with sysconfig settings' do
      let :params do
        {
          sysconfig_startup_options: '-u named -4',
          sysconfig_disable_zone_checking: true
        }
      end

      sysconfig_named_content = <<-SYSCONFIG
# This file is managed by Puppet.
#
# BIND named process options
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# OPTIONS="whatever"     --  These additional options will be passed to named
#                            at startup. Don't add -t here, enable proper
#                            -chroot.service unit file.
#                            Use of parameter -c is not supported here. Extend
#                            systemd named*.service instead. For more
#                            information please read the following KB article:
#                            https://access.redhat.com/articles/2986001
#
# DISABLE_ZONE_CHECKING  --  By default, service file calls named-checkzone
#                            utility for every zone to ensure all zones are
#                            valid before named starts. If you set this option
#                            to 'yes' then service file doesn't perform those
#                            checks.

OPTIONS="-u named -4"
DISABLE_ZONE_CHECKING="yes"
      SYSCONFIG

      it {
        should contain_file('/etc/sysconfig/named').with(
          owner: 'root',
          group: 'root',
          mode: '0644',
          content: sysconfig_named_content
        )
      }

    end

    describe 'with additional sysconfig settings' do
      let :params do
        {
          sysconfig_startup_options: '-u named -4',
          sysconfig_disable_zone_checking: true,
          sysconfig_additional_settings: {
            'FOO' => 'bar',
            'export SOMETHING' => 'other',
            'BAZ' => 'quux'
          }
        }
      end

      sysconfig_named_content = <<-SYSCONFIG
# This file is managed by Puppet.
#
# BIND named process options
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# OPTIONS="whatever"     --  These additional options will be passed to named
#                            at startup. Don't add -t here, enable proper
#                            -chroot.service unit file.
#                            Use of parameter -c is not supported here. Extend
#                            systemd named*.service instead. For more
#                            information please read the following KB article:
#                            https://access.redhat.com/articles/2986001
#
# DISABLE_ZONE_CHECKING  --  By default, service file calls named-checkzone
#                            utility for every zone to ensure all zones are
#                            valid before named starts. If you set this option
#                            to 'yes' then service file doesn't perform those
#                            checks.

OPTIONS="-u named -4"
DISABLE_ZONE_CHECKING="yes"

BAZ="quux"
FOO="bar"
export SOMETHING="other"
      SYSCONFIG

      it {
        should contain_file('/etc/sysconfig/named').with(
          owner: 'root',
          group: 'root',
          mode: '0644',
          content: sysconfig_named_content
        )
      }

    end
  end

  describe 'on FreeBSD with no custom parameters' do

    let(:facts) do
      {
         :clientcert => 'puppetmaster.example.com',
         :fqdn => 'puppetmaster.example.com',
         :osfamily => 'FreeBSD',
      }
    end

    describe 'with no custom parameters' do
      it { should contain_class('dns::install') }
      it { should contain_class('dns::config') }
      it { should contain_class('dns::service') }

      it { should contain_package('bind910').with_ensure('present') }
      it { should contain_group('bind') }

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

      it { should contain_concat('/usr/local/etc/namedb/zones.conf').with_validate_cmd('/usr/local/sbin/named-checkconf %') }
      it { should contain_concat('/usr/local/etc/namedb/named.conf').with_validate_cmd('/usr/local/sbin/named-checkconf %') }
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

    describe 'with group_manage false' do
      let(:params) { {:group_manage => false} }
      it { should_not contain_group('bind') }
    end

    describe 'with manage_service true' do
      let(:params) { {:manage_service => true} }
      it { should contain_service('named') }
    end

    describe 'with manage_service false' do
      let(:params) { {:manage_service => false} }
      it { should_not contain_service('named') }
    end
  end

  describe 'on Debian' do

    let(:facts) do
      {
         :clientcert     => 'puppetmaster.example.com',
         :fqdn           => 'puppetmaster.example.com',
         :osfamily       => 'Debian',
         :ipaddress      => '192.0.2.1',
      }
    end

    describe 'with no custom parameters' do
      it { should contain_class('dns::install') }
      it { should contain_class('dns::config') }
      it { should contain_class('dns::service') }

      it { should contain_package('bind9').with_ensure('present') }
      it { should contain_group('bind') }

      it { should contain_concat('/etc/bind/named.conf.options') }
      it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'directory "/var/cache/bind";',
          'recursion yes;',
          'allow-query { any; };',
          'dnssec-enable yes;',
          'dnssec-validation yes;',
          'empty-zones-enable yes;',
          'listen-on-v6 { any; };',
          'allow-recursion { localnets; localhost; };'
      ])}

      it { should contain_concat('/etc/bind/named.conf') }
      it { verify_concat_fragment_exact_contents(catalogue, 'named.conf+10-main.dns', [
          '// named.conf',
          'include "/etc/bind/rndc.key";',
          'controls  {',
          '        inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; };',
          '};',
          'options  {',
          '        include "/etc/bind/named.conf.options";',
          '};',
          'include "/etc/bind/zones.rfc1918";',
          '// Public view read by Server Admin',
          'include "/etc/bind/zones.conf";'
      ])}

      it { should contain_file('/var/cache/bind/zones').with_ensure('directory') }
      it { should contain_exec('create-rndc.key').
                  with_command("/usr/sbin/rndc-confgen -r /dev/urandom -a -c /etc/bind/rndc.key") }

      sysconfig_named_content = <<-SYSCONFIG
# This file is managed by Puppet.
#
# run resolvconf?
RESOLVCONF=no

# startup options for the server
OPTIONS="-u bind"
      SYSCONFIG

      it {
        should contain_file('/etc/default/bind9').with(
          owner: 'root',
          group: 'root',
          mode: '0644',
          content: sysconfig_named_content
        )
      }

      it { should contain_service('bind9').with_ensure('running').with_enable(true) }
    end

    describe 'with sysconfig settings' do
      let :params do
        {
          sysconfig_startup_options: '-u bind -4',
          sysconfig_resolvconf_integration: true,
        }
      end

      sysconfig_named_content = <<-SYSCONFIG
# This file is managed by Puppet.
#
# run resolvconf?
RESOLVCONF=yes

# startup options for the server
OPTIONS="-u bind -4"
      SYSCONFIG

      it {
        should contain_file('/etc/default/bind9').with(
          owner: 'root',
          group: 'root',
          mode: '0644',
          content: sysconfig_named_content
        )
      }
    end

    describe 'with additional sysconfig settings' do
      let :params do
        {
          sysconfig_startup_options: '-u bind -4',
          sysconfig_additional_settings: {
            'FOO' => 'bar',
            'export SOMETHING' => 'other',
            'BAZ' => 'quux'
          }
        }
      end

      sysconfig_named_content = <<-SYSCONFIG
# This file is managed by Puppet.
#
# run resolvconf?
RESOLVCONF=no

# startup options for the server
OPTIONS="-u bind -4"

BAZ="quux"
FOO="bar"
export SOMETHING="other"
      SYSCONFIG

      it {
        should contain_file('/etc/default/bind9').with(
          owner: 'root',
          group: 'root',
          mode: '0644',
          content: sysconfig_named_content
        )
      }
    end

    describe 'with manage_service true' do
      let(:params) { {:manage_service => true} }
      it { should contain_service('bind9') }
    end

    describe 'with manage_service false' do
      let(:params) { {:manage_service => false} }
      it { should_not contain_service('bind9') }
    end

  end
end

require 'spec_helper'

describe 'dns' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:package_name) do
        case facts[:os]['family']
        when 'Debian'
          'bind9'
        when 'FreeBSD'
          'bind916'
        else
          'bind'
        end
      end

      let(:group_name) do
        case facts[:os]['family']
        when 'RedHat'
          'named'
        when 'Archlinux'
          'named'
        else
          'bind'
        end
      end

      let(:sbin) { facts[:os]['family'] == 'FreeBSD' ? '/usr/local/sbin' : '/usr/sbin' }

      let(:etc_named_directory) do
        case facts[:os]['family']
        when 'Debian'
          '/etc/bind'
        when 'FreeBSD'
          '/usr/local/etc/namedb'
        when 'RedHat'
          '/etc/named'
        when 'Archlinux'
          '/etc'
        end
      end

      let(:options_path) do
        case facts[:os]['family']
        when 'Debian'
          '/etc/bind/named.conf.options'
        when 'Archlinux'
          "#{etc_named_directory}/named.options.conf"
        else
          "#{etc_named_directory}/options.conf"
        end
      end

      let(:etc_directory) { facts[:os]['family'] == 'RedHat' ? '/etc' : etc_named_directory }
      let(:rndc_key) { "#{etc_directory}/rndc.key" }

      let(:localzonepath) do
        case facts[:os]['family']
        when 'Debian'
          "#{etc_directory}/zones.rfc1918"
        when 'RedHat'
          "#{etc_directory}/named.rfc1912.zones"
        end
      end

      let(:defaultzonepath) do
        case facts[:os]['family']
        when 'Debian'
          "#{etc_directory}/named.conf.default-zones"
        end
      end

      let(:var_path) do
        case facts[:os]['family']
        when 'Debian'
          '/var/cache/bind'
        when 'FreeBSD'
          "#{etc_named_directory}/working"
        else
          '/var/named'
        end
      end

      let(:zonefilepath) do
        case facts[:os]['family']
        when 'Debian'
          "#{var_path}/zones"
        when 'FreeBSD'
          "#{etc_named_directory}/dynamic"
        else
          "#{var_path}/dynamic"
        end
      end

      let(:service_name) { facts[:os]['family'] == 'Debian' ? 'bind9' : 'named' }

      describe 'with no custom parameters' do
        it { should contain_class('dns::params') }
        it { should contain_class('dns::install') }
        it { should contain_class('dns::config') }
        it { should contain_class('dns::service') }

        it { should contain_package(package_name).with_ensure('installed') }
        it { should contain_group(group_name) }

        it { should contain_concat(options_path) }
        it do
          has_dnssec_enable = case facts[:os]['family']
                              when 'Debian'
                                ['9', '10', '18.04'].include?(facts[:os]['release']['major'])
                              when 'RedHat'
                                ['7', '8'].include?(facts[:os]['release']['major'])
                              else
                                false
                              end
          expected = [
            "directory \"#{var_path}\";",
            'recursion yes;',
            'allow-query { any; };',
            'dnssec-validation yes;',
            'empty-zones-enable yes;',
            'listen-on-v6 { any; };',
            'allow-recursion { localnets; localhost; };'
          ]

          expected << 'dnssec-enable yes;' if has_dnssec_enable

          if facts[:os]['family'] == 'FreeBSD'
            expected << 'pid-file "/var/run/named/pid";'
          end

          verify_concat_fragment_exact_contents(catalogue, 'options.conf+10-main.dns', expected)
        end

        it { should contain_concat("#{etc_named_directory}/zones.conf").with_validate_cmd("#{sbin}/named-checkconf %") }
        it { should contain_concat("#{etc_directory}/named.conf").with_validate_cmd("#{sbin}/named-checkconf %") }
        it do
          expected = [
            '// named.conf',
            "include \"#{rndc_key}\";",
            'controls  {',
            '        inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; };',
            '};',
            'options  {',
            "        include \"#{options_path}\";",
            '};',
            localzonepath ? "include \"#{localzonepath}\";" : nil,
            defaultzonepath ? "include \"#{defaultzonepath}\";" : nil,
            '// Public view read by Server Admin',
            "include \"#{etc_named_directory}/zones.conf\";",
          ].compact

          verify_concat_fragment_exact_contents(catalogue, 'named.conf+10-main.dns', expected)
        end

        it { should contain_file(zonefilepath).with_ensure('directory') }
        it do
          should contain_exec('create-rndc.key')
            .with_command("#{sbin}/rndc-confgen -a -c #{rndc_key}")
            .with_creates(rndc_key)
        end
        it { should contain_file(rndc_key) }

        it { should contain_service(service_name).with_ensure('running').with_enable(true).with_restart(nil) }
        it { is_expected.not_to contain_concat_fragment('named.conf+50-logging-header.dns') }
        it { is_expected.not_to contain_concat_fragment('named.conf+60-logging-footer.dns') }
      end

      describe 'with unmanaged localzonepath and unmanaged defaultzonepath' do

        let(:params) do {
          :localzonepath => 'unmanaged',
          :defaultzonepath => 'unmanaged',
        } end

        it { verify_concat_fragment_exact_contents(catalogue, 'named.conf+10-main.dns', [
          '// named.conf',
          "include \"#{rndc_key}\";",
          'controls  {',
          '        inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; };',
          '};',
          'options  {',
          "        include \"#{options_path}\";",
          '};',
          '// Public view read by Server Admin',
          "include \"#{etc_named_directory}/zones.conf\";",
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

        it do
          expected = [
            '// named.conf',
            "include \"#{rndc_key}\";",
            'controls  {',
            '        inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; };',
            '};',
            'options  {',
            "        include \"#{options_path}\";",
            '};',
            localzonepath ? "include \"#{localzonepath}\";" : nil,
            defaultzonepath ? "include \"#{defaultzonepath}\";" : nil,
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
            "include \"#{etc_named_directory}/zones.conf\";",
          ].compact


          verify_concat_fragment_exact_contents(catalogue, 'named.conf+10-main.dns', expected)
        end
      end

      describe 'with ipv6 disabled' do
        let(:params) { {:listen_on_v6 => 'none'} }

        it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'listen-on-v6 { none; };',
        ])}
      end

      describe 'with empty zones disabled' do
        let(:params) { {:empty_zones_enable => 'no'} }

        it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'empty-zones-enable no;',
        ])}
      end

      describe 'with dns_notify disabled' do
        let(:params) { {:dns_notify => 'no' } }

        it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'notify no;',
        ])}
      end

      describe 'with forward only' do
        let(:params) { {:forward => 'only'} }

        it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
          'forward only;',
        ])}
      end

      describe 'with undef forward' do
        let(:params) { {:forward => :undef} }

        it { should contain_concat_fragment('options.conf+10-main.dns').without_content('/forward ;/') }
      end

      describe 'with false listen_on_v6' do
        let(:params) { {:listen_on_v6 => false} }

        it { should contain_concat_fragment('options.conf+10-main.dns').without_content('/listen_on_v6/') }
      end

      describe 'with group_manage false' do
        let(:params) { {:group_manage => false} }

        it { should_not contain_group(group_name) }
      end

      context 'service' do
        describe 'with service_ensure stopped' do
          let(:params) { {:service_ensure => 'stopped'} }

          it { should contain_service(service_name).with_ensure('stopped').with_enable(true) }
        end

        describe 'with service_enable false' do
          let(:params) { {:service_enable => false} }

          it { should contain_service(service_name).with_ensure('running').with_enable(false) }
        end

        describe 'with service_restart_command set to "/usr/sbin/service bind9 reload' do
          let(:params) { {:service_restart_command => '/usr/sbin/service bind9 reload'} }
          it {
            should contain_service(service_name)
              .with_ensure('running')
              .with_enable(true)
              .with_restart('/usr/sbin/service bind9 reload')
          }
        end

        describe 'with manage_service true' do
          let(:params) { {:manage_service => true} }
          it { should contain_service(service_name) }
        end

        describe 'with manage_service false' do
          let(:params) { {:manage_service => false} }
          it { should_not contain_service(service_name) }
        end
      end

      describe 'with acls set' do
        let(:params) { {:acls => { 'trusted_nets' => [ '127.0.0.1/24', '127.0.1.0/24' ] } } }

        it { verify_concat_fragment_contents(catalogue, 'named.conf+10-main.dns', [
          'acl "trusted_nets"  {',
          '        127.0.0.1/24;',
          '        127.0.1.0/24;',
          '};',
        ])}
      end

      describe 'with additional options' do
        let(:params) { { :additional_options => { 'max-cache-ttl' => 3600, 'max-ncache-ttl' => 3600 } } }

        it { verify_concat_fragment_contents(catalogue, 'options.conf+10-main.dns', [
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
        it { should contain_file("#{zonefilepath}/db.example.com") }
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
        it { should contain_concat__fragment('named.conf+20-key-dns-key.dns') }
        it { should contain_exec('create-dns-key.key') }
        it { should contain_file("#{etc_directory}/dns-key.key") }
      end

      describe 'with config_check set to false' do
        let(:params) { { :config_check => false } }

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_concat("#{etc_directory}/named.conf")
            .without_validate_cmd()
        }
      end

      context 'sysconfig', if: ['Debian', 'RedHat'].include?(os_facts[:os]['family']) do
        let(:sysconfig_named_path) do
          case facts[:os]['family']
          when 'RedHat'
            '/etc/sysconfig/named'
          when 'Debian'
            '/etc/default/bind9'
          end
        end

        describe 'default parameters' do
          let(:sysconfig_named_content) do
            case facts[:os]['family']
            when 'RedHat'
              <<~SYSCONFIG
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
            when 'Debian'
              <<~SYSCONFIG
                # This file is managed by Puppet.
                #
                # run resolvconf?
                RESOLVCONF=no

                # startup options for the server
                OPTIONS="-u bind"
              SYSCONFIG
            end
          end

          it do
            should contain_file(sysconfig_named_path).with(
              owner: 'root',
              group: 'root',
              mode: '0644',
              content: sysconfig_named_content
            )
          end
        end

        describe 'with Red Hat sysconfig settings', if: os_facts[:os]['family'] == 'RedHat' do
          let :params do
            {
              sysconfig_startup_options: '-u named -4',
              sysconfig_disable_zone_checking: true
            }
          end

          let(:sysconfig_named_content) do
            <<~SYSCONFIG
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
          end

          it {
            should contain_file(sysconfig_named_path).with(
              owner: 'root',
              group: 'root',
              mode: '0644',
              content: sysconfig_named_content
            )
          }
        end

        describe 'with Debian sysconfig settings', if: os_facts[:os]['family'] == 'Debian' do
          let :params do
            {
              sysconfig_startup_options: '-u bind -4',
              sysconfig_resolvconf_integration: true,
            }
          end

          let(:sysconfig_named_content) do
            <<~SYSCONFIG
              # This file is managed by Puppet.
              #
              # run resolvconf?
              RESOLVCONF=yes

              # startup options for the server
              OPTIONS="-u bind -4"
            SYSCONFIG
          end

          it {
            should contain_file(sysconfig_named_path).with(
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
              sysconfig_additional_settings: {
                'FOO' => 'bar',
                'export SOMETHING' => 'other',
                'BAZ' => 'quux'
              }
            }
          end

          it {
            verify_contents(catalogue, sysconfig_named_path, [
              'BAZ="quux"',
              'FOO="bar"',
              'export SOMETHING="other"',
            ])
          }
        end
      end
      context 'scl', if: ['RedHat'].include?(os_facts[:os]['family']) do
        describe 'with RedHat SCL', if: os_facts[:os]['family'] == 'RedHat' do
          let(:manifest) do
            <<-EOS
          class { 'dns::globals':
            scl => 'isc-bind'
          }
          include dns
            EOS
          end
          it {
            should contain_file('/usr/bin/dig').with(
              owner: 'root',
              group: 'root',
              mode: '0755',
              content: /.*isc-bind.*/
            )
            should contain_file('/usr/bin/nsupdate').with(
              owner: 'root',
              group: 'root',
              mode: '0755',
              content: /.*isc-bind.*/
            )
          }
        end
      end
    end
  end
end

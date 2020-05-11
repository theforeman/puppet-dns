require 'spec_helper'

describe 'dns::zone' do

  rndc_policy_params = {
    :update_policy => {
      'rndc-key' => {
        'matchtype' => 'zonesub',
        'rr'        => 'ANY'
      },
    },
  }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(fqdn: 'puppetmaster.example.com') }
      let(:title) { "example.com" }
      let(:pre_condition) { 'include dns' }
      let(:zonefilepath) do
        case facts[:os]['family']
        when 'Debian'
          '/var/cache/bind/zones'
        when 'FreeBSD'
          '/usr/local/etc/namedb/dynamic'
        else
          '/var/named/dynamic'
        end
      end

      let(:user_name) do
        case facts[:os]['family']
        when 'RedHat'
          'named'
        when 'Archlinux'
          'named'
        else
          'bind'
        end
      end

      it { is_expected.to compile.with_all_deps }

      it "should have valid zone configuration" do
        verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
          'zone "example.com" {',
          '    type master;',
          "    file \"#{zonefilepath}/db.example.com\";",
          '};',
        ])
      end

      it "should create zone file" do
        should contain_file("#{zonefilepath}/db.example.com").with({
          :owner    => user_name,
          :group    => user_name,
          :mode     => '0644',
          :replace  => 'false',
        }).that_notifies('Class[Dns::Service]')
      end

      it "should have valid zone file contents" do
        verify_exact_contents(catalogue, "#{zonefilepath}/db.example.com", [
          '$TTL 10800',
          '@ IN SOA puppetmaster.example.com. root.example.com. (',
          '	1	;Serial',
          '	86400	;Refresh',
          '	3600	;Retry',
          '	604800	;Expire',
          '	3600	;Negative caching TTL',
          ')',
          '@ IN NS puppetmaster.example.com.',
        ])
      end

      context 'when reverse => true' do
        let(:title) { '1.168.192.in-addr.arpa' }
        let(:params) {{ :reverse => true }}

        it "should have valid zone file contents" do
          verify_exact_contents(catalogue, "#{zonefilepath}/db.1.168.192.in-addr.arpa", [
            '$TTL 10800',
            '@ IN SOA puppetmaster.example.com. root.1.168.192.in-addr.arpa. (',
            '	1	;Serial',
            '	86400	;Refresh',
            '	3600	;Retry',
            '	604800	;Expire',
            '	3600	;Negative caching TTL',
            ')',
            '@ IN NS puppetmaster.example.com.',
          ])
        end
      end

      context 'with soaip and soaipv6' do
        let(:params) { { soaip: '192.0.2.1', soaipv6: '2001:db8::1' } }

        it "should have valid zone file contents" do
          verify_exact_contents(catalogue, "#{zonefilepath}/db.example.com", [
            '$TTL 10800',
            '@ IN SOA puppetmaster.example.com. root.example.com. (',
            '	1	;Serial',
            '	86400	;Refresh',
            '	3600	;Retry',
            '	604800	;Expire',
            '	3600	;Negative caching TTL',
            ')',
            '@ IN NS puppetmaster.example.com.',
            'puppetmaster.example.com. IN A 192.0.2.1',
            'puppetmaster.example.com. IN AAAA 2001:db8::1',
          ])
        end
      end

      context 'when allow_transfer defined' do
        let(:params) {rndc_policy_params.merge({ :allow_transfer => ['192.168.1.2'] })}

        it "should have valid zone configuration with allow-transfer" do
          verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
            'zone "example.com" {',
            '    type master;',
            "    file \"#{zonefilepath}/db.example.com\";",
            '    update-policy {',
            '            grant rndc-key zonesub ANY;',
            '    };',
            '    allow-transfer { 192.168.1.2; };',
            '};',
          ])
        end

        context 'when allow_transfer with multiple values' do
          let(:params) {rndc_policy_params.merge({ :allow_transfer => ['192.168.1.2', '192.168.1.3'] })}

          it "should have valid zone configuration with allow-transfer" do
            verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
              'zone "example.com" {',
              '    type master;',
              "    file \"#{zonefilepath}/db.example.com\";",
              '    update-policy {',
              '            grant rndc-key zonesub ANY;',
              '    };',
              '    allow-transfer { 192.168.1.2; 192.168.1.3; };',
              '};',
            ])
          end
        end
      end

      context 'when also_notify defined' do
        let(:params) {rndc_policy_params.merge({ :also_notify => ['192.168.1.2'] })}

        it "should have valid zone configuration with also-notify" do
          verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
            'zone "example.com" {',
            '    type master;',
            "    file \"#{zonefilepath}/db.example.com\";",
            '    update-policy {',
            '            grant rndc-key zonesub ANY;',
            '    };',
            '    also-notify { 192.168.1.2; };',
            '};',
          ])
        end

        context 'when also_notify with multiple values' do
          let(:params) {rndc_policy_params.merge({ :also_notify => ['192.168.1.2', '192.168.1.3'] })}

          it "should have valid zone configuration with also-notify" do
            verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
              'zone "example.com" {',
              '    type master;',
              "    file \"#{zonefilepath}/db.example.com\";",
              '    update-policy {',
              '            grant rndc-key zonesub ANY;',
              '    };',
              '    also-notify { 192.168.1.2; 192.168.1.3; };',
              '};',
            ])
          end
        end
      end

      context 'when zonetype => slave' do
        let(:params) {{ :zonetype => 'slave', :masters  => ['192.168.1.1'] }}

        it "should have valid slave zone configuration" do
          verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
            'zone "example.com" {',
            '    type slave;',
            "    file \"#{zonefilepath}/db.example.com\";",
            '    masters { 192.168.1.1; };',
            '    notify no;',
            '};',
          ])
        end

        context 'when multiple masters defined' do
          let(:params) {{ :zonetype => 'slave', :masters  => ['192.168.1.1', '192.168.1.2'] }}

          it "should have valid slave zone configuration" do
            verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
              'zone "example.com" {',
              '    type slave;',
              "    file \"#{zonefilepath}/db.example.com\";",
              '    masters { 192.168.1.1; 192.168.1.2; };',
              '    notify no;',
              '};',
            ])
          end
        end

        context 'when dns_notify => no' do
          let(:params) {rndc_policy_params.merge({ :dns_notify => 'no' })}

          it "should have valid slave zone configuration" do
            verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
              'zone "example.com" {',
              '    type master;',
              "    file \"#{zonefilepath}/db.example.com\";",
              '    update-policy {',
              '            grant rndc-key zonesub ANY;',
              '    };',
              '    notify no;',
              '};',
            ])
          end
        end

        context 'with allow query' do
            let(:params) {{ :zonetype => 'slave', :masters  => ['192.168.1.1', '192.168.1.2'], :allow_query => ['1.2.3.4'] }}

          it "should have valid slave zone configuration" do
            verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
              'zone "example.com" {',
              '    type slave;',
              "    file \"#{zonefilepath}/db.example.com\";",
              '    allow-query { 1.2.3.4; };',
              '    masters { 192.168.1.1; 192.168.1.2; };',
              '    notify no;',
              '};',
            ])
          end
        end

        context 'views enabled with nonexisting view' do
          let(:params) {{ :target_views => ['nonexistent'] }}
          let :pre_condition do
            'class { "::dns": enable_views => true }'
          end
          it { is_expected.to_not compile }
        end

        context 'views enabled with existing view' do
          let(:params) {{ :target_views => ['existing'] }}
          let :pre_condition do
            'class { "::dns": enable_views => true }
             dns::view { "existing": }
            '
          end
          it { is_expected.to compile }
        end

        context 'views feature with two views' do
          let(:params) {{ :target_views => ['office', 'dmz'] }}

          let :pre_condition do
            'class { "::dns": enable_views => true }
             dns::view { "office": }
             dns::view { "dmz": }
            '
          end
          it "should have valid slave zone configuration in office view" do
            verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10_office_example.com.dns', [
              'zone "example.com" {',
              '    type master;',
              "    file \"#{zonefilepath}/db.example.com\";",
              '};',
            ])
          end

          it "should have valid slave zone configuration in dmz view" do
            verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10_dmz_example.com.dns', [
              'zone "example.com" {',
              '    type master;',
              "    file \"#{zonefilepath}/db.example.com\";",
              '};',
            ])
          end

          it { should_not contain_concat__fragment('dns_zones+10__GLOBAL__example.com.dns') }

        end

      end

      context 'when zonetype => forward' do
        let(:params) {{ :zonetype => 'forward', :forward => 'only', :forwarders => ['192.168.3.4', '192.168.5.6'] }}

        it "should have valid forward zone configuration" do
          verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
            'zone "example.com" {',
            '    type forward;',
            '    forward only;',
            '    forwarders { 192.168.3.4; 192.168.5.6; };',
            '};',
          ])
        end

        context 'when parameters are set that are not allowed options for zonetype => forward' do
          let(:params) {{
            :zonetype => 'forward',
            :forwarders => ['192.168.3.4', '192.168.5.6'],
            :manage_file => true,
            :manage_file_name => true,
            :masters  => ['192.168.1.1', '192.168.1.2'],
            :allow_transfer => ['192.168.100.1'],
            :allow_query => ['192.168.100.1'],
            :also_notify => ['192.168.100.1'],
            :dns_notify => 'explicit'
          }}

          it "should have valid forward zone configuration without options that are not allowed" do
            verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
              'zone "example.com" {',
              '    type forward;',
              '    forward first;',
              '    forwarders { 192.168.3.4; 192.168.5.6; };',
              '};',
            ])
          end
        end

      end

      context 'update_policy with multiple declarations' do
        let(:params) { {
          :update_policy => {
            'foreman_key' => {
              'matchtype' => 'zonesub',
              'rr'        => 'ANY'
            },
            'goreman_key' => {
              'action'    => 'deny',
              'matchtype' => 'subdomain',
              'rr'        => 'ANY'
            },
          }
        } }

        it "should have valid zone configuration" do
          verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
          'zone "example.com" {',
          '    type master;',
          "    file \"#{zonefilepath}/db.example.com\";",
          '    update-policy {',
          '            grant foreman_key zonesub ANY;',
          '            deny goreman_key subdomain ANY;',
          '    };',
          '};',
        ])
        end
      end

      context 'update_policy uses non-default key' do
        let(:params) { {
          :update_policy => {
            'foreman_key' => {
              'matchtype' => 'zonesub',
              'tname' => '*',
              'rr' => 'ANY'
            }
          }
        } }

        it "should have valid zone configuration" do
          verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
          'zone "example.com" {',
          '    type master;',
          "    file \"#{zonefilepath}/db.example.com\";",
          '    update-policy {',
          '            grant foreman_key zonesub * ANY;',
          '    };',
          '};',
        ])
        end
      end

      context 'update_policy set to local' do
        let(:params) { {
          :update_policy => 'local',
        } }

        it "should have valid zone configuration" do
          verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
          'zone "example.com" {',
          '    type master;',
          "    file \"#{zonefilepath}/db.example.com\";",
          '    update-policy local;',
          '};',
        ])
        end
      end

      context 'when several dnssec related parameters are set' do
        let(:params) { {
          :inline_signing            => 'yes',
          :dnssec_secure_to_insecure => 'yes',
          :key_directory             => '/etc/bind/keys',
          :auto_dnssec               => 'maintain',
          :update_policy             => 'local',
        } }

        it "should have valid zone configuration" do
          verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
          'zone "example.com" {',
          '    type master;',
          "    file \"#{zonefilepath}/db.example.com\";",
          '    auto-dnssec maintain;',
          '    dnssec-secure-to-insecure yes;',
          '    inline-signing yes;',
          '    key-directory "/etc/bind/keys";',
          '    update-policy local;',
          '};',
        ])
        end
      end
    end
  end
end

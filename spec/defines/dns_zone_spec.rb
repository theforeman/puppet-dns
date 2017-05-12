require 'spec_helper'

describe 'dns::zone' do

  let(:facts) do
    {
      :clientcert     => 'puppetmaster.example.com',
      :concat_basedir => '/doesnotexist',
      :fqdn           => 'puppetmaster.example.com',
      :ipaddress      => '192.168.1.1',
      :osfamily       => 'RedHat',
    }
  end

  let(:title) { "example.com" }

  let :pre_condition do
    'include dns'
  end

  it "should have valid zone configuration" do
    verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
      'zone "example.com" {',
      '    type master;',
      '    file "/var/named/dynamic/db.example.com";',
      '    update-policy {',
      '            grant rndc-key zonesub ANY;',
      '    };',
      '};',
    ])
  end

  it "should create zone file" do
    should contain_file('/var/named/dynamic/db.example.com').with({
      :owner    => 'named',
      :group    => 'named',
      :mode     => '0644',
      :replace  => 'false',
      :notify   => 'Service[named]',
    })
  end

  it "should have valid zone file contents" do
    verify_exact_contents(catalogue, '/var/named/dynamic/db.example.com', [
      '$TTL 10800',
      '@ IN SOA puppetmaster.example.com. root.example.com. (',
      '	1	;Serial',
      '	86400	;Refresh',
      '	3600	;Retry',
      '	604800	;Expire',
      '	3600	;Negative caching TTL',
      ')',
      '@ IN NS puppetmaster.example.com.',
      'puppetmaster.example.com. IN A 192.168.1.1',
    ])
  end

  context 'when reverse => true' do
    let(:title) { '1.168.192.in-addr.arpa' }
    let(:params) {{ :reverse => true }}

    it "should have valid zone file contents" do
      verify_exact_contents(catalogue, '/var/named/dynamic/db.1.168.192.in-addr.arpa', [
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

  context 'when allow_transfer defined' do
    let(:params) {{ :allow_transfer => ['192.168.1.2'] }}

    it "should have valid zone configuration with allow-transfer" do
      verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
        'zone "example.com" {',
        '    type master;',
        '    file "/var/named/dynamic/db.example.com";',
        '    update-policy {',
        '            grant rndc-key zonesub ANY;',
        '    };',
        '    allow-transfer { 192.168.1.2; };',
        '};',
      ])
    end

    context 'when allow_transfer with multiple values' do
      let(:params) {{ :allow_transfer => ['192.168.1.2', '192.168.1.3'] }}

      it "should have valid zone configuration with allow-transfer" do
        verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
          'zone "example.com" {',
          '    type master;',
          '    file "/var/named/dynamic/db.example.com";',
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
    let(:params) {{ :also_notify => ['192.168.1.2'] }}

    it "should have valid zone configuration with also-notify" do
      verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
        'zone "example.com" {',
        '    type master;',
        '    file "/var/named/dynamic/db.example.com";',
        '    update-policy {',
        '            grant rndc-key zonesub ANY;',
        '    };',
        '    also-notify { 192.168.1.2; };',
        '};',
      ])
    end

    context 'when also_notify with multiple values' do
      let(:params) {{ :also_notify => ['192.168.1.2', '192.168.1.3'] }}

      it "should have valid zone configuration with also-notify" do
        verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
          'zone "example.com" {',
          '    type master;',
          '    file "/var/named/dynamic/db.example.com";',
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
        '    file "/var/named/dynamic/db.example.com";',
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
          '    file "/var/named/dynamic/db.example.com";',
          '    masters { 192.168.1.1; 192.168.1.2; };',
          '    notify no;',
          '};',
        ])
      end
    end

    context 'when dns_notify => no' do
      let(:params) {{ :dns_notify => 'no' }}

      it "should have valid slave zone configuration" do
        verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10__GLOBAL__example.com.dns', [
          'zone "example.com" {',
          '    type master;',
          '    file "/var/named/dynamic/db.example.com";',
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
          '    file "/var/named/dynamic/db.example.com";',
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
          '    file "/var/named/dynamic/db.example.com";',
          '    update-policy {',
          '            grant rndc-key zonesub ANY;',
          '    };',
          '};',
        ])
      end

      it "should have valid slave zone configuration in dmz view" do
        verify_concat_fragment_exact_contents(catalogue, 'dns_zones+10_dmz_example.com.dns', [
          'zone "example.com" {',
          '    type master;',
          '    file "/var/named/dynamic/db.example.com";',
          '    update-policy {',
          '            grant rndc-key zonesub ANY;',
          '    };',
          '};',
        ])
      end

      it { should_not contain_concat__fragment('dns_zones+10__GLOBAL__example.com.dns') }

    end

  end

end

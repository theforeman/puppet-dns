require 'spec_helper'

describe 'dns::zone' do

  let(:facts) do
    {
      :osfamily   => 'RedHat',
      :fqdn       => 'puppetmaster.example.com',
      :clientcert => 'puppetmaster.example.com',
      :ipaddress  => '192.168.1.1'
    }
  end

  let(:title) { "example.com" }

  it "should have valid zone configuration" do
    verify_concat_fragment_exact_contents(subject, 'dns_zones+10_example.com.dns', [
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
    verify_exact_contents(subject, '/var/named/dynamic/db.example.com', [
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
      verify_exact_contents(subject, '/var/named/dynamic/db.1.168.192.in-addr.arpa', [
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
      verify_concat_fragment_exact_contents(subject, 'dns_zones+10_example.com.dns', [
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
        verify_concat_fragment_exact_contents(subject, 'dns_zones+10_example.com.dns', [
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

  context 'when zonetype => slave' do
    let(:params) {{ :zonetype => 'slave', :masters  => ['192.168.1.1'] }}

    it "should have valid slave zone configuration" do
      verify_concat_fragment_exact_contents(subject, 'dns_zones+10_example.com.dns', [
        'zone "example.com" {',
        '    type slave;',
        '    file "/var/named/dynamic/db.example.com";',
        '    masters { 192.168.1.1; };',
        '};',
      ])
    end

    context 'when multiple masters defined' do
      let(:params) {{ :zonetype => 'slave', :masters  => ['192.168.1.1', '192.168.1.2'] }}

      it "should have valid slave zone configuration" do
        verify_concat_fragment_exact_contents(subject, 'dns_zones+10_example.com.dns', [
          'zone "example.com" {',
          '    type slave;',
          '    file "/var/named/dynamic/db.example.com";',
          '    masters { 192.168.1.1; 192.168.1.2; };',
          '};',
        ])
      end
    end
  end

  context 'when soa is not a part of the zone' do
    let(:params) {{ :soa => 'foo.example.tld', :zone => 'example.com' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/soa must be within the defined zone/)
    end
  end
end

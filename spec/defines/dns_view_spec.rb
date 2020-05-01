require 'spec_helper'

describe 'dns::view' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { "default" }

      context "without dns::enable_view flag set" do
        let :pre_condition do
          'include dns'
        end

        it { is_expected.to_not compile }
      end

      context "with default configuration" do
        let :pre_condition do
          'class {"::dns": enable_views => true}'
        end

        it { should compile.with_all_deps }

        it "should have default view configuration" do
          dns = catalogue.resource('Class', 'dns').to_hash
          localzonepath   = dns[:localzonepath]
          defaultzonepath = dns[:defaultzonepath]
          verify_concat_fragment_exact_contents(catalogue, 'dns_view_header_default.dns',
            [ 'view "default" {' ] +
            (localzonepath   == 'unmanaged' ? [] : ["include \"#{localzonepath}\";"]) +
            (defaultzonepath == 'unmanaged' ? [] : ["include \"#{defaultzonepath}\";"])
          )
        end
      end

      context "with minimal view content" do
        let(:title) { "minimal" }
        let :pre_condition do
          'class {"::dns": enable_views => true}'
        end
        let(:params) { { include_localzones: false, include_defaultzones: false } }

        it { should compile.with_all_deps }

        it "should have minimal view configuration" do
          verify_concat_fragment_exact_contents(catalogue, 'dns_view_header_minimal.dns', [
            'view "minimal" {',
          ])
        end
      end

      context "with fully parameterized configuration" do
        let(:title) { "full" }
        let :pre_condition do
          'class {"::dns": enable_views => true}'
        end
        let(:params) { {
          match_clients:        ['0.0.0.0/0'],
          match_destinations:   ['0.0.0.0/1'],
          match_recursive_only: 'yes',
          allow_transfer:       ['0.0.0.0/2'],
          allow_recursion:      ['0.0.0.0/3'],
          allow_query:          ['0.0.0.0/4'],
          allow_query_cache:    ['0.0.0.0/5'],
          also_notify:          ['10.0.0.10'],
          forwarders:           ['10.0.0.11'],
          forward:              'first',
          recursion:            'yes',
          dnssec_enable:        'yes',
          dnssec_validation:    'yes',
          dns_notify:           'explicit',
          include_localzones:   true,
          include_defaultzones: true,
          order:                '1',
        } }

        it { should compile.with_all_deps }

        it "should have full view configuration" do
          dns = catalogue.resource('Class', 'dns').to_hash
          localzonepath   = dns[:localzonepath]
          defaultzonepath = dns[:defaultzonepath]
          verify_concat_fragment_exact_contents(catalogue, 'dns_view_header_full.dns',
            [ 'view "full" {' ] +
            [ '    forward first;',
              '    forwarders { 10.0.0.11; };',
              '    match-clients { 0.0.0.0/0; };',
              '    match-destinations { 0.0.0.0/1; };',
              '    allow-transfer { 0.0.0.0/2; };',
              '    allow-recursion { 0.0.0.0/3; };',
              '    allow-query { 0.0.0.0/4; };',
              '    allow-query-cache { 0.0.0.0/5; };',
              '    also-notify { 10.0.0.10; };',
              '    notify explicit;',
              '    match-recursive-only yes;',
              '    recursion yes;',
              '    dnssec-enable yes;',
              '    dnssec-validation yes;',
            ] +
            (localzonepath   == 'unmanaged' ? [] : ["include \"#{localzonepath}\";"]) +
            (defaultzonepath == 'unmanaged' ? [] : ["include \"#{defaultzonepath}\";"])
          )
        end
      end
    end
  end
end

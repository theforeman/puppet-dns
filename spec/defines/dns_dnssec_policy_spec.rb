require 'spec_helper'

describe 'dns::dnssec_policy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { "standard" }

      let :pre_condition do
        'include dns'
      end

      context "without params" do
        it { is_expected.to compile }

        it "should have valid zone file contents" do
          verify_concat_fragment_exact_contents(catalogue, 'dnssec-policy-standard', [
            'dnssec-policy standard {',
            '};',
          ])
        end

        context "when using a reserved name" do
          let(:title) { "default" }

          it { is_expected.to compile.and_raise_error(/The name "default" is reserved and cannot be used/) }
        end
      end


      context "with all params set" do
        let(:params) do
          {
            dnskey_ttl: 600,
            keys: [
              {
                type: "ksk",
                directory: "key-directory",
                lifetime: "unlimited",
                algorithm: "rsasha1",
                size: 2048,
              },
              {
                type: "zsk",
                lifetime: "P30D",
                algorithm: 8,
              },
              {
                type: "csk",
                lifetime: "P6MT12H3M15S",
                algorithm: "ecdsa256",
              },
            ],
            max_zone_ttl: 600,
            parent_ds_ttl: 600,
            parent_propagation_delay: "2h",
            publish_safety: "7d",
            retire_safety: "7d",
            signatures_refresh: "5d",
            signatures_validity: "15d",
            signatures_validity_dnskey: "15d",
            zone_propagation_delay: "2h",
          }
        end

        it { is_expected.to compile }

        it "should have valid zone file contents" do
          verify_concat_fragment_exact_contents(catalogue, 'dnssec-policy-standard', [
            'dnssec-policy standard {',
            '    dnskey-ttl 600;',
            '    keys {',
            '        ksk key-directory lifetime unlimited algorithm rsasha1 2048;',
            '        zsk lifetime P30D algorithm 8;',
            '        csk lifetime P6MT12H3M15S algorithm ecdsa256;',
            '    };',
            '    max-zone-ttl 600;',
            '    parent-ds-ttl 600;',
            '    parent-propagation-delay 2h;',
            '    publish-safety 7d;',
            '    retire-safety 7d;',
            '    signatures-refresh 5d;',
            '    signatures-validity 15d;',
            '    signatures-validity-dnskey 15d;',
            '    zone-propagation-delay 2h;',
            '};',
          ])
        end
      end
    end
  end
end

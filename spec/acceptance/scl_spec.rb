require 'spec_helper_acceptance'

if fact('osfamily') == 'RedHat'
  describe 'Scenario: install scl-bind' do

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        yumrepo{'bind_scl':
          descr    => 'copr repo for bind owned by isc'
          baseurl  =>  "https://download.copr.fedorainfracloud.org/results/isc/bind/epel-$facts['os']['release']['major']-x86_64/"
          gpgcheck =>  0

        }
        class { 'dns::globals':
          scl => 'isc-bind'
        }
        include dns

        dns::zone { 'example.com':
          soa     => 'ns1.example.com',
          soaip   => '192.0.2.1',
          soaipv6 => '2001:db8::1',
        }
        EOS
      end
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(53) do
      it { is_expected.to be_listening }
    end

    describe command('dig +short SOA example.com @localhost') do
      its(:stdout) { is_expected.to match("ns1.example.com. root.example.com. 1 86400 3600 604800 3600\n") }
    end
  end
end

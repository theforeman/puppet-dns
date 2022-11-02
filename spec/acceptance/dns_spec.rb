require 'spec_helper_acceptance'

describe 'Scenario: install bind' do
  it_behaves_like 'an idempotent resource' do
    let(:manifest) do
      <<-EOS
      include dns

      dns::zone { 'example.com':
        soa     => 'ns1.example.com',
        soaip   => '192.0.2.1',
        soaipv6 => '2001:db8::1',
      }
      EOS
    end
  end

  service_name = fact('osfamily') == 'Debian' ? 'bind9' : 'named'

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

  before(:context) do
    describe command('dnf remove -y bind bind-utils') do
      its(:stdout) { should match /Removed:/ }
    end
  end

  after(:context) do
    describe command('dnf remove -y isc-bind isc-bind-bind-utils') do
      its(:stdout) { should match /Removed:/ }
    end
  end

end

require 'spec_helper_acceptance'

describe 'Scenario: install bind' do
  before(:context) do
    case fact('osfamily')
    when 'Debian'
      utils = 'dnsutils'
    else
      utils = 'bind-utils'
    end

    on default, puppet("resource package #{utils} ensure=present")
  end

  let(:pp) do
    <<-EOS
    include ::dns

    dns::zone { 'example.com':
      soa => 'ns1.example.com',
    }
    EOS
  end

  it_behaves_like 'a idempotent resource'

  service_name = case fact('osfamily')
                 when 'Debian'
                   'bind9'
                 else
                   'named'
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

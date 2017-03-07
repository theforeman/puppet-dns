require 'spec_helper_acceptance'

describe 'Scenario: install bind with views enabled' do
  before(:context) do
    case fact('osfamily')
    when 'Debian'
      package_name = 'bind9'
      utils = 'dnsutils'
    else
      package_name = 'bind'
      utils = 'bind-utils'
    end

    on default, puppet("resource package #{package_name} ensure=absent")
    on default, puppet("resource package #{utils} ensure=present")
    on default, 'rm -rf /var/named /var/cache/bind'
  end

  context 'with views enabled' do
    let(:pp) do
      <<-EOS
      class {'::dns':
        enable_views => true,
      }

      dns::view { 'v4':
        match_clients => ['0.0.0.0/0'],
      }

      dns::view { 'v6':
        match_clients => ['::/0'],
      }

      dns::zone { 'example.com-v4':
        zone         => 'example.com',
        soa          => 'ns1-v4.example.com',
        filename     => 'db.example.com-v4',
        target_views => ['v4'],
      }

      dns::zone { 'example.com-v6':
        zone         => 'example.com',
        soa          => 'ns1-v6.example.com',
        filename     => 'db.example.com-v6',
        target_views => ['v6'],
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

    describe command('dig +short SOA example.com @127.0.0.1') do
      its(:stdout) { is_expected.to match("ns1-v4.example.com. root.example.com. 1 86400 3600 604800 3600\n") }
    end

    describe command('dig +short SOA example.com @::1') do
      its(:stdout) { is_expected.to match("ns1-v6.example.com. root.example.com. 1 86400 3600 604800 3600\n") }
    end
  end
end

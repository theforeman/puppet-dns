require 'spec_helper_acceptance'

describe 'Scenario: install bind with logging enabled' do
  context 'with logging enabled' do
    let(:pp) do
      <<-EOS
      class { 'dns':
        logging_categories => {
          queries => {
            channels => ['queries_file'],
          },
        },
        logging_channels   => {
          queries_file => {
            file_path     => '/var/log/named/queries.log',
            file_versions => 6,
            file_size     => '50m',
            log_type      => 'file',
            severity      => 'dynamic',
            print_time    => 'yes',
          },
        },
      }

      dns::zone { 'example.com':
        soa                => 'ns1.example.com',
        soaip              => '192.0.2.1',
        soaipv6            => '2001:db8::1',
      }
      EOS
    end

    it_behaves_like 'a idempotent resource'

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

    describe file('/var/log/named/queries.log') do
      its(:content) { is_expected.to match(%r{query: example\.com IN SOA \+}) }
    end
  end
end

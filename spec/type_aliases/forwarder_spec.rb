require 'spec_helper'

describe 'Dns::Forwarder' do
  it { is_expected.not_to allow_value(nil) }
  it { is_expected.not_to allow_value('') }

  describe 'IPv4' do
    it { is_expected.to allow_value('192.0.2.1') }
    it { is_expected.to allow_value('192.0.2.1 port 5353') }
    it { is_expected.to allow_value('192.168.254.254    port     5353') }
    it { is_expected.to allow_value('192.168.254.254    port     65534') }
  end

  describe 'IPv6' do
    it { is_expected.to allow_value('::1') }
    it { is_expected.to allow_value('::1 port 5353') }
    it { is_expected.to allow_value('2001:db8:1234:5678:9ABC:DEF::1') }
    it { is_expected.to allow_value('2001:db8:1234:5678:9ABC:DEF::1 port 5353') }
    it { is_expected.to allow_value('2001:0db8:1234:5678:9ABC:0DEF:0000:0001') }
    it { is_expected.to allow_value('2001:0db8:1234:5678:9ABC:0DEF:0000:0001 port 65534') }
  end
end

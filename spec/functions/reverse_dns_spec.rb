require 'spec_helper'

describe 'dns::reverse_dns' do
  it { is_expected.to run.with_params('192.0.2.100').and_return('100.2.0.192.in-addr.arpa') }
  it { is_expected.to run.with_params('2001:db8::').and_return('0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa') }
  it { is_expected.to run.with_params('2001:db8').and_raise_error(ArgumentError, /parameter 'ip' expects a Stdlib::IP::Address::Nosubnet/) }
end

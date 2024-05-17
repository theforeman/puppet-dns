require 'spec_helper'

describe 'dns::tsig_keygen' do
  it 'without algorithm' do
    output = <<~OUTPUT
      key "myname" {
      \talgorithm hmac-sha256;
      \tsecret "r9SlgbRyks9gGTAIbnjwGX1UxVxY8k0q1wbyiqTolLs=";
      };
    OUTPUT

    expect(Puppet::Util::Execution).to receive(:execute).with(['tsig-keygen', 'myname'], failonfail: true).and_return(output)
    expected = {
      'name' => 'myname',
      'algorithm' => 'hmac-sha256',
      'secret' => 'r9SlgbRyks9gGTAIbnjwGX1UxVxY8k0q1wbyiqTolLs=',
      'output' => output,
    }

    is_expected.to run.with_params('myname').and_return(expected)
  end

  it 'with algorithm' do
    output = <<~OUTPUT
      key "myname" {
      \talgorithm hmac-md5;
      \tsecret "RHwgNynk1A7cc+fnH2rxqQ==";
      };
    OUTPUT

    expect(Puppet::Util::Execution).to receive(:execute).with(['tsig-keygen', '-a', 'hmac-md5', 'myname'], failonfail: true).and_return(output)
    expected = {
      'name' => 'myname',
      'algorithm' => 'hmac-md5',
      'secret' => 'RHwgNynk1A7cc+fnH2rxqQ==',
      'output' => output,
    }

    is_expected.to run.with_params('myname', 'hmac-md5').and_return(expected)
  end
end

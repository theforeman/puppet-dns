require 'spec_helper'

describe 'dns::dnssec_keygen' do
  it do
    expect(Puppet::Util::Execution).to receive(:execute).with(['dnssec-keygen', '-K', kind_of(String), '-a', 'ED25519', 'myname'], failonfail: true) do |command, **kwargs|
      dir = command[2]
      content = <<~PRIVATE
        Private-key-format: v1.3
        Algorithm: 15 (ED25519)
        PrivateKey: 7F1qiEoDLvTLlOv+xY46MyI3vtcncqme+DExkz5YiRg=
        Created: 20240130104725
        Publish: 20240130104725
        Activate: 20240130104725
      PRIVATE
      File.write(File.join(dir, 'Kmyname.+015+04808.private'), content)
    end
    expected = {
      'Private-key-format' => 'v1.3',
      'Algorithm' => '15 (ED25519)',
      'PrivateKey' => '7F1qiEoDLvTLlOv+xY46MyI3vtcncqme+DExkz5YiRg=',
      'Created' => '20240130104725',
      'Publish' => '20240130104725',
      'Activate' => '20240130104725',
    }

    is_expected.to run.with_params('myname', 'ED25519').and_return(expected)
  end
end

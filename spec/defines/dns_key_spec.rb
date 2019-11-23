require 'spec_helper'

describe 'dns::key' do
  let(:facts) do
    {
      :clientcert     => 'puppetmaster.example.com',
      :fqdn           => 'puppetmaster.example.com',
      :osfamily       => 'RedHat',
    }
  end

  let(:title) { 'foreman_key' }

  let :pre_condition do
    'include dns'
  end

  it { is_expected.to compile }
  it { is_expected.to contain_exec('create-foreman_key.key') }

  context 'secret set' do
    let(:params) do
      {
        :secret => 'top_secret',
      }
    end
    it 'should contain a file with the secret in it' do
      is_expected.to contain_file('/etc/foreman_key.key')
      verify_contents(catalogue, '/etc/foreman_key.key', [
        'key "foreman_key" {',
        '    algorithm hmac-md5;',
        '    secret "top_secret";',
        '};',
      ])
      verify_concat_fragment_exact_contents(catalogue, 'named.conf+20-key-foreman_key.dns', [
        'include "/etc/foreman_key.key";',
      ])

    end
  end
end

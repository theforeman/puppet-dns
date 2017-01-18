require 'spec_helper'

describe 'dns::view' do

  let(:facts) do
    {
      :clientcert     => 'puppetmaster.example.com',
      :concat_basedir => '/doesnotexist',
      :fqdn           => 'puppetmaster.example.com',
      :ipaddress      => '192.168.1.1',
      :osfamily       => 'RedHat',
    }
  end

  let(:title) { "default" }

  context "without dns::enable_view flag set" do
    let :pre_condition do
      'include dns'
    end
    it { is_expected.to_not compile }
  end

  context "with dns::enable_view flag set" do
    let :pre_condition do
      'class {"::dns": enable_views => true}'
    end
    it { should compile.with_all_deps }
  end


end

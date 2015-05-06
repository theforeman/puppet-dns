require 'spec_helper'

describe 'dns::record' do

  let(:facts) do
    {
      :osfamily   => 'RedHat',
      :fqdn       => 'puppetmaster.example.com',
      :clientcert => 'puppetmaster.example.com',
      :ipaddress  => '192.168.1.1'
    }
  end

  let :pre_condition do
    'include dns'
  end

  context 'when creating CNAME record' do
    let(:title) { "foo.example.com" }
    let(:params) {{ 
      :target => "vm123.example.com.",
      :type   => "CNAME",
      :comment => "Created by vm123",
    }}
  
    it "should have valid record configuration" do
      verify_concat_fragment_exact_contents(subject, 'dns-static-example.com+02content-foo.example.com.dnsstatic', [
        'foo IN CNAME vm123.example.com.  ; Created by vm123',
      ])
    end
  end

  context 'when creating SRV record' do
    let(:title) { "www.example.com-http-backend1" }
    let(:params) {{ 
      :target => "vm123.example.com.",
      :label  => "_http._tcp.www.example.com.",
      :zone   => "example.com",
      :priority => "10",
      :weight   => "60",
      :port     => "80",
      :type   => "SRV",
      :comment => "Created by vm123",
    }}
  
    it "should have valid record configuration" do
      verify_concat_fragment_exact_contents(subject, 'dns-static-example.com+02content-www.example.com-http-backend1.dnsstatic', [
        '_http._tcp.www.example.com. IN SRV 10 60 80 vm123.example.com.  ; Created by vm123',
      ])
    end
  end

  context 'when creating CNAME with blank target' do
    let(:title) { "badcname.example.com" }
    let(:params) {{ 
      :type   => "CNAME",
      :comment => "Created by vm123",
    }}
    
    it { should_not compile }
  end

end

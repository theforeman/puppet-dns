require 'spec_helper'

describe 'dns::logging::category' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(fqdn: 'puppetmaster.example.com') }
      let(:pre_condition) { 'include dns' }
      let(:title) { 'test' }
      let(:logdir) { '/var/log/named' }

      describe 'without channels set' do
        it { is_expected.not_to compile }
      end

      describe 'with channels set' do
        let(:params) { { 'channels' => ['test_channel'] } }

        it { is_expected.to compile.with_all_deps }

        it 'should have valid category contents' do
          verify_concat_fragment_exact_contents(
            catalogue,
            "named.conf-logging-category-#{title}.dns",
            [
              '  category test {',
              '    test_channel;',
              '  };',
            ]
          )
        end

        it {
          is_expected.to contain_concat_fragment(
            "named.conf-logging-category-#{title}.dns"
          ).with('order' => 55)
        }

        it { is_expected.to contain_file(logdir).with_ensure('directory') }
        it {
          is_expected.to contain_concat_fragment(
            'named.conf+50-logging-header.dns'
          ).with('order' => 50).with('content' => "logging {\n")
        }
        it {
          is_expected.to contain_concat_fragment(
            'named.conf+60-logging-footer.dns'
          ).with('order' => 60).with('content' => "};\n")
        }
      end

      describe 'when order => 59' do
        let(:params) do
          {
            'channels' => ['test_channel'],
            'order'    => 59,
          }
        end

        it {
          is_expected.to contain_concat_fragment(
            "named.conf-logging-category-#{title}.dns"
          ).with('order' => 59)
        }
      end

      describe 'fail when order => 50' do
        let(:params) do
          {
            'channels' => ['test_channel'],
            'order'    => 50,
          }
        end

        it { is_expected.not_to compile }
      end

      describe 'fail when order => 60' do
        let(:params) do
          {
            'channels' => ['test_channel'],
            'order'    => 60,
          }
        end

        it { is_expected.not_to compile }
      end
    end
  end
end

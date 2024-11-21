require 'spec_helper'

describe 'dns::logging::channel' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { override_facts(os_facts, networking: { fqdn: 'puppetmaster.example.com' }) }
      let(:pre_condition) { 'include dns' }
      let(:title) { 'test' }
      let(:logdir) { '/var/log/named' }

      describe 'without log_type set' do
        it { is_expected.not_to compile }
      end

      describe 'with log_type = null set' do
        let(:params) { { 'log_type' => 'null' } }

        it { is_expected.to compile.with_all_deps }

        it 'should have valid channel contents' do
          verify_concat_fragment_exact_contents(
            catalogue,
            "named.conf-logging-channel-#{title}.dns",
            [
              '  channel test {',
              '    null;',
              '  };',
            ]
          )
        end

        it {
          is_expected.to contain_concat_fragment(
            "named.conf-logging-channel-#{title}.dns"
          ).with('order' => 51)
        }

        it { should contain_file(logdir).with_ensure('directory') }
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

      describe 'with log_type = null set and order = 55' do
        let(:params) do
          {
            'log_type' => 'null',
            'order'    => 55,
          }
        end

        it {
          is_expected.to contain_concat_fragment(
            "named.conf-logging-channel-#{title}.dns"
          ).with('order' => 55)
        }
      end

      describe 'with log_type = stderr set' do
        let(:params) { { 'log_type' => 'stderr' } }

        it 'should have valid channel contents' do
          verify_concat_fragment_exact_contents(
            catalogue,
            "named.conf-logging-channel-#{title}.dns",
            [
              '  channel test {',
              '    stderr;',
              '  };',
            ]
          )
        end

        it {
          is_expected.to contain_concat_fragment(
            "named.conf-logging-channel-#{title}.dns"
          ).with('order' => 51)
        }
      end

      describe 'with log_type = syslog and syslog_facility not set' do
        let(:params) { { 'log_type' => 'syslog' } }

        it { is_expected.not_to compile }
      end

      describe 'with log_type = syslog and syslog_facility set' do
        let(:params) do
          {
            'log_type'        => 'syslog',
            'syslog_facility' => 'auth',
          }
        end

        it 'should have valid channel contents' do
          verify_concat_fragment_exact_contents(
            catalogue,
            "named.conf-logging-channel-#{title}.dns",
            [
              '  channel test {',
              '    syslog auth;',
              '  };',
            ]
          )
        end
      end

      describe 'with log_type = file and other options not set' do
        let(:params) { { 'log_type' => 'file' } }

        it { is_expected.not_to compile }
      end

      describe 'with log_type = file and file_path not set' do
        let(:params) do
          {
            'log_type'      => 'file',
            'file_size'     => '5m',
            'file_versions' => 3,
          }
        end

        it { is_expected.not_to compile }
      end

      describe 'with log_type = file and file_size not set' do
        let(:params) do
          {
            'log_type'      => 'file',
            'file_path'     => '/path/to/file.log',
            'file_versions' => 3,
          }
        end

        it { is_expected.not_to compile }
      end

      describe 'with log_type = file and file_size not an integer set' do
        let(:params) do
          {
            'log_type'      => 'file',
            'file_path'     => '/path/to/file.log',
            'file_versions' => '3',
          }
        end

        it { is_expected.not_to compile }
      end

      describe 'with log_type = file and file_size and file_version not set' do
        let(:params) do
          {
            'log_type'      => 'file',
            'file_path'     => '/path/to/file.log',
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      describe 'with log_type = file and file_versions not set' do
        let(:params) do
          {
            'log_type'  => 'file',
            'file_path' => '/path/to/file.log',
            'file_size' => '5m',
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      describe 'with log_type = syslog and all options set' do
        let(:params) do
          {
            'log_type'      => 'file',
            'file_path'     => '/path/to/file.log',
            'file_size'     => '5m',
            'file_versions' => 4,
          }
        end

        it 'should have valid channel contents' do
          verify_concat_fragment_exact_contents(
            catalogue,
            "named.conf-logging-channel-#{title}.dns",
            [
              '  channel test {',
              '    file "/path/to/file.log" versions 4 size 5m;',
              '  };',
            ]
          )
        end
      end

      describe 'with severity set' do
        let(:params) do
          {
            'log_type' => 'stderr',
            'severity' => 'dynamic',
          }
        end

        it 'should have valid channel contents' do
          verify_concat_fragment_exact_contents(
            catalogue,
            "named.conf-logging-channel-#{title}.dns",
            [
              '  channel test {',
              '    stderr;',
              '    severity dynamic;',
              '  };',
            ]
          )
        end
      end

      describe 'with print_category set' do
        let(:params) do
          {
            'log_type'       => 'stderr',
            'print_category' => 'yes',
          }
        end

        it 'should have valid channel contents' do
          verify_concat_fragment_exact_contents(
            catalogue,
            "named.conf-logging-channel-#{title}.dns",
            [
              '  channel test {',
              '    stderr;',
              '    print-category yes;',
              '  };',
            ]
          )
        end
      end

      describe 'with print_severity set' do
        let(:params) do
          {
            'log_type'       => 'stderr',
            'print_severity' => 'yes',
          }
        end

        it 'should have valid channel contents' do
          verify_concat_fragment_exact_contents(
            catalogue,
            "named.conf-logging-channel-#{title}.dns",
            [
              '  channel test {',
              '    stderr;',
              '    print-severity yes;',
              '  };',
            ]
          )
        end
      end

      describe 'with print_time set' do
        let(:params) do
          {
            'log_type'   => 'stderr',
            'print_time' => 'yes',
          }
        end

        it 'should have valid channel contents' do
          verify_concat_fragment_exact_contents(
            catalogue,
            "named.conf-logging-channel-#{title}.dns",
            [
              '  channel test {',
              '    stderr;',
              '    print-time yes;',
              '  };',
            ]
          )
        end
      end

      describe 'fail when order => 50' do
        let(:params) do
          {
            'log_type' => 'stderr',
            'order'    => 50,
          }
        end

        it { is_expected.to compile.and_raise_error(%r{order}) }
      end

      describe 'fail when order => 60' do
        let(:params) do
          {
            'log_type' => 'stderr',
            'order'    => 60,
          }
        end

        it { is_expected.to compile.and_raise_error(%r{order}) }
      end
    end
  end
end

require 'spec_helper'

describe 'dns::view' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
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
  end
end

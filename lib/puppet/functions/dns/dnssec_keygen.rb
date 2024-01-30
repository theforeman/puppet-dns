require 'tmpdir'

# @summary Generate a DNSSEC key
Puppet::Functions.create_function(:'dns::dnssec_keygen') do
  dispatch :keygen do
    param 'String[1]', :name
    param "String[1]", :algorithm
    optional_param 'Integer[1, 4096]', :keysize
    optional_param 'String[1]', :nametype
    return_type 'Hash[String, String]'
  end

  def keygen(name, algorithm, keysize: nil, nametype: nil)
    Dir.mktmpdir do |dir|
      command = ['dnssec-keygen', '-K', dir]
      command << '-a' << algorithm if algorithm
      command << '-k' << keysize if keysize
      command << '-n' << nametype if nametype
      command << name
      Puppet::Util::Execution.execute(command, failonfail: true)

      path = Dir.glob(File.join(dir, "K#{name}.+*.private")).first
      raise Exception, 'No file private key generated' unless path

      File.readlines(path, chomp: true).to_h { |line| line.split(': ', 2) }
    end
  end
end

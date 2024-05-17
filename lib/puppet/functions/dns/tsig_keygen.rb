require 'tmpdir'

# @summary Generate a TSIG key
Puppet::Functions.create_function(:'dns::tsig_keygen') do
  dispatch :keygen do
    param 'String[1]', :name
    optional_param "String[1]", :algorithm
    return_type 'Hash[String, String]'
  end

  def keygen(name, algorithm = nil)
    command = ['tsig-keygen']
    command << '-a' << algorithm if algorithm
    command << name
    output = Puppet::Util::Execution.execute(command, failonfail: true)

    header, rest = output.split('{', 2)
    inner, _, _ = rest.rpartition('}').first
    options = inner.strip.split(';').to_h do |line|
      match = line.match(/^\s*(?<option>[a-z]+)\s+(?<quote>"?)(?<value>.+)\k<quote>\s*$/)
      [match[:option], match[:value]]
    end

    {
      'name' => header.match(/key "(.+)\s*"/)[1],
      'output' => output,
    }.merge(options)
  end
end

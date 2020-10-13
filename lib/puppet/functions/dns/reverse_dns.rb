require 'ipaddr'

# @summary Get the reverse DNS for an IP address
Puppet::Functions.create_function(:'dns::reverse_dns') do
  # @param ip
  #   The IP address to get the reverse for
  dispatch :reverse do
    param 'Stdlib::IP::Address::Nosubnet', :ip
    return_type 'Stdlib::Fqdn'
  end

  def reverse(ip)
    IPAddr.new(ip).reverse
  end
end

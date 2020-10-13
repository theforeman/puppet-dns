# @summary DEPRECATED.  Use the [`dns::reverse_dns`](#dnsreverse_dns) function instead.
Puppet::Functions.create_function(:get_in_addr_arpa) do
  dispatch :deprecation_gen do
    repeated_param 'Any', :args
  end
  def deprecation_gen(*args)
    call_function('deprecation', 'get_in_addr_arpa', 'This method is deprecated, please use dns::reverse_dns instead.')
    call_function('dns::reverse_dns', *args)
  end
end

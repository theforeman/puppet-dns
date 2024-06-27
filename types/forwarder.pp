# @summary a DNS forwarder entry
#
# A forwarder is an IP address (v4 or v6) with optionally followed a port.
# Since we can't compose patterns, this copies stdlib's implementation for v4.
# For v6 it uses the default type and grossly simplifies the port check for simplicity.
type Dns::Forwarder = Variant[
  Pattern[/\A([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])){3}(\s+port\s+[0-9]{1,5})?\z/],
  Stdlib::IP::Address::V6::Nosubnet,
  # This is a really gross simplification of IPv6
  Pattern[/(\A(:{0,2}[[:xdigit:]]{1,4}){1,8}\s+port\s[0-9]{1,5}\Z)/],
]

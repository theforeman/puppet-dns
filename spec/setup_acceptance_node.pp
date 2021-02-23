# This provides dig which we use in our tests
$package = $facts['os']['family'] ? {
  'Debian' => 'dnsutils',
  default  => 'bind-utils',
}

package { $package:
  ensure => installed,
}

# Needed for the ss and sysctl commands in testing and not included in the base container
if $facts['os']['name'] == 'Fedora' {
  package { ['iproute', 'procps-ng']:
    ensure => installed,
  }
}

# The both IPv4 and IPv6 are used to test views
exec { 'sysctl -w net.ipv6.conf.all.disable_ipv6=0':
  path => ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
}

# This provides dig which we use in our tests
$package = $facts['os']['family'] ? {
  'Debian' => 'dnsutils',
  default  => 'bind-utils',
}

package { $package:
  ensure => installed,
}

# Needed for the ss command in testing and not included in the base container
if $facts['os']['name'] == 'Fedora' {
  package { 'iproute':
    ensure => installed,
  }
}

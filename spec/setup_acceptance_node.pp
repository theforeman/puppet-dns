# This provides dig which we use in our tests
$package = $facts['os']['family'] ? {
  'Debian' => 'dnsutils',
  default  => 'bind-utils',
}

package { $package:
  ensure => installed,
}

# Configure dns
class dns::config {
  group { $dns::params::group: }

  concat { $::dns::publicviewpath:
    owner => root,
    group => $dns::params::group,
    mode  => '0640',
  }

  file { $::dns::viewconfigpath:
    ensure => directory,
    owner  => root,
    group  => $dns::params::group,
    mode   => '0755',
  }

  concat::fragment { 'dns_zones+01-header.dns':
    target  => $::dns::publicviewpath,
    content => ' ',
    order   => '01',
  }

  concat { [$::dns::namedconf_path, $::dns::optionspath]:
    owner => root,
    group => $::dns::params::group,
    mode  => '0640',
  }

  concat::fragment { 'named.conf+10-main.dns':
    target  => $::dns::namedconf_path,
    content => template($::dns::namedconf_template),
    order   => '10',
  }

  concat::fragment { 'options.conf+10-main.dns':
    target  => $::dns::optionspath,
    content => template($::dns::optionsconf_template),
    order   => '10',
  }

  file { $dns::zonefilepath:
    ensure => directory,
    owner  => $dns::params::user,
    group  => $dns::params::group,
    mode   => '0640',
  }

  exec { 'create-rndc.key':
    command => "${dns::rndcconfgen} -r /dev/urandom -a -c ${dns::rndckeypath}",
    creates => $dns::rndckeypath,
  } ->
  file { $dns::rndckeypath:
    owner => 'root',
    group => $dns::params::group,
    mode  => '0640',
  }
}

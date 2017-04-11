# Configure dns
class dns::config {
  group { $dns::params::group: }

  concat_file { $::dns::publicviewpath:
    owner => root,
    group => $dns::params::group,
    mode  => '0640',
    tag   => 'concat_file_publicviewport',
  }

  concat_fragment { 'dns_zones+01-header.dns':
    target  => $::dns::publicviewpath,
    content => ' ',
    order   => '01',
    tag     => 'concat_file_publicviewport',
  }

  concat_file { $::dns::namedconf_path:
    owner => root,
    group => $::dns::params::group,
    mode  => '0640',
    tag   => 'concat_file_namedconf_path',
  }
  concat_file { $::dns::optionspath:
    owner => root,
    group => $::dns::params::group,
    mode  => '0640',
    tag   => 'concat_file_optionspath',
  }
  concat_fragment { 'named.conf+10-main.dns':
    target  => $::dns::namedconf_path,
    content => template($::dns::namedconf_template),
    order   => '10',
    tag     => 'concat_file_namedconf_path',
  }

  concat_fragment { 'options.conf+10-main.dns':
    target  => $::dns::optionspath,
    content => template($::dns::optionsconf_template),
    order   => '10',
    tag     => 'concat_file_optionspath',
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
  }
  -> file { $dns::rndckeypath:
    owner => 'root',
    group => $dns::params::group,
    mode  => '0640',
  }
}

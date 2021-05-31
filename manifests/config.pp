# Configure dns
# @api private
class dns::config {
  if $dns::config_check {
    $validate_cmd = "${dns::named_checkconf} %"
  } else {
    $validate_cmd = undef
  }

  concat { $dns::publicviewpath:
    owner        => root,
    group        => $dns::params::group,
    mode         => '0640',
    validate_cmd => $validate_cmd,
  }

  if $dns::enable_views {
    file { $dns::viewconfigpath:
      ensure => directory,
      owner  => root,
      group  => $dns::params::group,
      mode   => '0755',
    }
  }

  concat::fragment { 'dns_zones+01-header.dns':
    target  => $dns::publicviewpath,
    content => ' ',
    order   => '01',
  }

  concat { $dns::namedconf_path:
    owner        => 'root',
    group        => $dns::params::group,
    mode         => '0640',
    require      => Concat[$dns::optionspath],
    validate_cmd => $validate_cmd,
  }

  # This file cannot be checked by named-checkconf because its content is only
  # valid inside an "options { };" directive.
  concat { $dns::optionspath:
    owner => 'root',
    group => $dns::params::group,
    mode  => '0640',
  }

  concat::fragment { 'named.conf+10-main.dns':
    target  => $dns::namedconf_path,
    content => template($dns::namedconf_template),
    order   => '10',
  }

  concat::fragment { 'options.conf+10-main.dns':
    target  => $dns::optionspath,
    content => template($dns::optionsconf_template),
    order   => '10',
  }

  file { $dns::zonefilepath:
    ensure => directory,
    owner  => $dns::params::user,
    group  => $dns::params::group,
    mode   => '0640',
  }

  exec { 'create-rndc.key':
    command => "${dns::rndcconfgen} -a -c ${dns::rndckeypath}",
    creates => $dns::rndckeypath,
  }
  -> file { $dns::rndckeypath:
    owner => 'root',
    group => $dns::params::group,
    mode  => '0640',
  }

  # Only Debian and RedHat OS provide a sysconfig or default file where we can
  # set startup options and other environment settings for named. In FreeBSD
  # such settings must be set in the global, common /etc/rc.conf file and under
  # ArchLinux we must use systemd override files to change the startup
  # commandline. These cases are outside of this module's scope.
  if $facts['os']['family'] in ['Debian', 'RedHat'] {
    file { $dns::sysconfig_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template($dns::sysconfig_template),
    }
  }
}

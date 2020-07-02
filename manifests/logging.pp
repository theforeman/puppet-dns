# Enable logging for named
# @api private
class dns::logging {
  file { $dns::logdir:
    ensure => directory,
    owner  => $dns::params::user,
    group  => $dns::params::group,
    mode   => '0755',
  }

  concat::fragment { 'named.conf+50-logging-header.dns':
    target  => $dns::namedconf_path,
    content => "logging {\n",
    order   => 50,
  }

  concat::fragment { 'named.conf+60-logging-footer.dns':
    target  => $dns::namedconf_path,
    content => "};\n",
    order   => 60,
  }
}

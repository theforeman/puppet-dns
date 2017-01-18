# Define new view for the dns
define dns::view (
    $match_clients        = [],
    $match_destinations   = [],
    $match_recursive_only = 'no',

    $allow_transfer       = [],
    $allow_recursion      = [],
    $allow_query          = [],
    $allow_query_cache    = [],

    $also_notify          = [],
    $forwarders           = [],
    $forward              = 'first',
    $recursion            = 'yes',
    $dnssec_enable        = 'yes',
    $dnssec_validation    = 'yes',
    $dns_notify           = 'yes',
    $include_localzones   = true,
    $order                = '-',
) {
  validate_array($match_clients, $match_destinations, $allow_transfer, $allow_recursion, $allow_query, $allow_query_cache, $also_notify, $forwarders)
  validate_re($forward, '^(first|only)$', 'Only \'first\' or \'only\' are valid values for forward field')

  validate_re($recursion, '^(yes|no)$', 'Only \'yes\' and \'no\' are valid values for recursion field')
  validate_re($dnssec_enable, '^(yes|no)$', 'Only \'yes\' and \'no\' are valid values for dnssec_enable field')
  validate_re($dnssec_validation, '^(yes|no|auto)$', 'Only \'yes\', \'no\' and \'auto\' are valid values for dnssec_validation field')
  validate_re($match_recursive_only, '^(yes|no)$', 'Only \'yes\' or \'no\' are valid values for match_recursive_only field')
  validate_re($dns_notify, '^(yes|no)$', 'Only \'yes\' or \'no\' are valid values for dns_notify field')

  unless $::dns::enable_views { fail('Must set $dns::enable_views to true in order to use dns::view') }

  $viewconfigfile = "${::dns::viewconfigpath}/${title}.conf"

  concat::fragment { "dns_view_include_${title}.dns":
    target  => $::dns::publicviewpath,
    content => "include \"${viewconfigfile}\";\n",
    order   => $order,
  }

  concat { $viewconfigfile:
    owner  => root,
    group  => $dns::params::group,
    mode   => '0640',
    notify => Service[$::dns::namedservicename],
  }

  concat::fragment { "dns_view_header_${title}.dns":
    target  => $viewconfigfile,
    content => template('dns/named.view_header.erb'),
    order   => "${title}-10",
  }
  concat::fragment { "dns_view_footer_${title}.dns":
    target  => $viewconfigfile,
    content => "};\n",
    order   => "${title}-14",
  }

}

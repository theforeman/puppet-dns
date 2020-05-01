# Define new view for the dns
define dns::view (
  Array[String]                         $match_clients        = [],
  Array[String]                         $match_destinations   = [],
  Optional[Enum['yes','no']]            $match_recursive_only = undef,
  Array[String]                         $allow_transfer       = [],
  Array[String]                         $allow_recursion      = [],
  Array[String]                         $allow_query          = [],
  Array[String]                         $allow_query_cache    = [],
  Array[String]                         $also_notify          = [],
  Array[String]                         $forwarders           = [],
  Optional[Enum['only','first']]        $forward              = undef,
  Optional[Enum['yes','no']]            $recursion            = undef,
  Optional[Enum['yes','no']]            $dnssec_enable        = undef,
  Optional[Enum['yes','no']]            $dnssec_validation    = undef,
  Optional[Enum['yes','no','explicit']] $dns_notify           = undef,
  Boolean                               $include_localzones   = true,
  Boolean                               $include_defaultzones = true,
  String                                $order                = '-',
) {

  unless $dns::enable_views {
    fail('Must set $dns::enable_views to true in order to use dns::view')
  }

  $viewconfigfile = "${dns::viewconfigpath}/${title}.conf"

  concat::fragment { "dns_view_include_${title}.dns":
    target  => $dns::publicviewpath,
    content => "include \"${viewconfigfile}\";\n",
    order   => $order,
  }

  concat { $viewconfigfile:
    owner  => root,
    group  => $dns::params::group,
    mode   => '0640',
    notify => Class['dns::service'],
    before => Concat[$dns::publicviewpath],
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

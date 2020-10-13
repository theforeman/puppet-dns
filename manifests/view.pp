# @summary Define new view for the dns
# @see https://kb.isc.org/docs/aa-00851
#
# @param match_clients
#   The value for match-clients in the view definition
# @param match_destinations
#   The value for match-destinations in the view definition
# @param match_recursive_only
#   The value for match-recursive-only in the view definition
# @param allow_transfer
#   The value for allow-transfer in the view definition
# @param allow_recursion
#   The value for allow-recursion in the view definition
# @param allow_query
#   The value for allow-query in the view definition
# @param allow_query_cache
#   The value for allow-query-cache in the view definition
# @param also_notify
#   The value for also-notify in the view definition
# @param forwarders
#   The value for forwarders in the view definition
# @param forward
#   The value for forward in the view definition. Only used if forwarders is
#   not empty.
# @param recursion
#   The value for recursion in the view definition
# @param dnssec_enable
#   The value for dnssec-enable in the view definition
# @param dnssec_validation
#   The value for dnssec-validation in the view definition
# @param dns_notify
#   The value for notify in the view definition
# @param include_localzones
#    Whether to include the local zones or not. Requires dns::localzonepath not
#    to be unmanaged to be effective.
# @param include_defaultzones
#    Whether to include the default zones or not. Requires dns::defaultzonepath
#    not to be unmanaged to be effective.
# @param order
#   The order parameter to the concat fragment.
#
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

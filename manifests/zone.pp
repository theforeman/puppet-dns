# @summary Define new zone for the dns
#
# @param soaip
#   The IP address for the SOA. If `reverse` is false, an A record will be
#   created pointing to this IP address for `$soa`. This only makes sense if
#   `$soa` is withing this zone and needs glue records.
#
# @param soaipv6
#   The IPv6 address for the SOA. If `reverse` is false, an AAAA record will be
#   created pointing to this IP address for `$soa`. This only makes sense if
#   `$soa` is withing this zone and needs glue records.
#
# @param manage_file
#   Whether the manage the file resource. When true $manage_file_name is implied.
#
# @param manage_file_name
#   Whether to set the file parameter in the zone file.
#
# @param update_policy
#   This can be used to specifiy additional update policy rules in the
#   following format
#   { '<KEY_NAME' => {'matchtype' => '<VALUE>', 'tname' => '<VALUE>', 'rr' => 'VALUE' } }
#   Example {'foreman_key' => {'matchtype' => 'zonesub', 'rr' => 'ANY'}}
#   tname and rr are optional
#
define dns::zone (
  Array[String] $target_views                             = [],
  String $zonetype                                        = 'master',
  String $soa                                             = $fqdn,
  Boolean $reverse                                        = false,
  String $ttl                                             = '10800',
  Optional[Stdlib::IP::Address::V4] $soaip                = undef,
  Optional[Stdlib::IP::Address::V6] $soaipv6              = undef,
  Integer $refresh                                        = 86400,
  Integer $update_retry                                   = 3600,
  Integer $expire                                         = 604800,
  Integer $negttl                                         = 3600,
  Integer $serial                                         = 1,
  Array $masters                                          = [],
  Array $allow_transfer                                   = [],
  Array $allow_query                                      = [],
  Array $also_notify                                      = [],
  String $zone                                            = $title,
  Optional[String] $contact                               = undef,
  Stdlib::Absolutepath $zonefilepath                      = $dns::zonefilepath,
  String $filename                                        = "db.${title}",
  Boolean $manage_file                                    = true,
  Boolean $manage_file_name                               = false,
  Enum['first', 'only'] $forward                          = 'first',
  Array $forwarders                                       = [],
  Optional[Enum['yes', 'no', 'explicit']] $dns_notify     = undef,
  Optional[Dns::UpdatePolicy] $update_policy              = undef,
  Optional[Stdlib::Absolutepath] $key_directory           = undef,
  Optional[Enum['yes', 'no']] $inline_signing             = undef,
  Optional[Enum['yes', 'no']] $dnssec_secure_to_insecure  = undef,
  Optional[Enum['allow', 'maintain', 'off']] $auto_dnssec = undef,
) {

  $_contact = pick($contact, "root.${zone}.")

  $zonefilename = "${zonefilepath}/${filename}"

  if $dns::enable_views {
    if $target_views == [] {
      warning('You seem to mix BIND views with global zones, which will probably fail')
      $_target_views = ['_GLOBAL_']
    } else {
      $_target_views = $target_views
    }
  } else {
    $_target_views = ['_GLOBAL_']
  }

  if $zonetype == 'slave' {
    $_dns_notify = pick($dns_notify, 'no')
  } else {
    $_dns_notify = $dns_notify
  }

  $_target_views.each |$view| {
    $target = $view ? {
      '_GLOBAL_' => $dns::publicviewpath,
      default    => "${dns::viewconfigpath}/${view}.conf",
    }

    concat::fragment { "dns_zones+10_${view}_${title}.dns":
      target  => $target,
      content => template('dns/named.zone.erb'),
      order   => "${view}-11-${zone}-1",
    }

    unless ($view == '_GLOBAL_' or defined(Dns::View[$view])) {
      fail("Please define a dns::view '${view}' before using it as a dns::zone target")
    }
  }

  if $manage_file {
    file { $zonefilename:
      ensure  => file,
      owner   => $dns::user,
      group   => $dns::group,
      mode    => '0644',
      content => template('dns/zone.header.erb'),
      replace => false,
      notify  => Class['dns::service'],
    }
  }
}

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
# @param replace_file
#   Whether to update the zone file when a change is detected.
#
# @param update_policy
#   This can be used to specifiy additional update policy rules in the
#   following format
#   { '<KEY_NAME' => {'matchtype' => '<VALUE>', 'tname' => '<VALUE>', 'rr' => 'VALUE' } }
#   Example {'foreman_key' => {'matchtype' => 'zonesub', 'rr' => 'ANY'}}
#   tname and rr are optional
#
# @param target_views
# @param zonetype
# @param soa
# @param reverse
# @param ttl
# @param refresh
# @param update_retry
# @param expire
# @param negttl
# @param serial
# @param records
#   A list of records which will be added to the zone file in
#   the RFC 1035 format (see https://datatracker.ietf.org/doc/html/rfc1035)
#   Example ['host1 IN A 192.168.0.10', 'alt-host1 IN CNAME host1']
#
# @param masters
# @param allow_transfer
# @param allow_query
# @param allow_update
# @param also_notify
# @param zone
# @param contact
# @param zonefilepath
# @param filename
# @param forward
# @param forwarders
# @param dns_notify
# @param key_directory
# @param inline_signing
# @param dnssec_secure_to_insecure
# @param auto_dnssec
# @param dnssec_policy
#   Causes the zone to be signed and turns on automatic maintenance for the zone.
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
  Array[String[1]] $records                               = [],
  Array $masters                                          = [],
  Array $allow_transfer                                   = [],
  Array $allow_query                                      = [],
  Array $allow_update                                     = [],
  Array $also_notify                                      = [],
  String $zone                                            = $title,
  Optional[String] $contact                               = undef,
  Stdlib::Absolutepath $zonefilepath                      = $dns::zonefilepath,
  String $filename                                        = "db.${title}",
  Boolean $manage_file                                    = true,
  Boolean $manage_file_name                               = false,
  Boolean $replace_file                                   = false,
  Enum['first', 'only'] $forward                          = 'first',
  Array $forwarders                                       = [],
  Optional[Enum['yes', 'no', 'explicit']] $dns_notify     = undef,
  Optional[Dns::UpdatePolicy] $update_policy              = undef,
  Optional[Stdlib::Absolutepath] $key_directory           = undef,
  Optional[Enum['yes', 'no']] $inline_signing             = undef,
  Optional[Enum['yes', 'no']] $dnssec_secure_to_insecure  = undef,
  Optional[Enum['allow', 'maintain', 'off']] $auto_dnssec = undef,
  Optional[String[1]] $dnssec_policy                      = undef,
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
  if !$allow_update.empty and $update_policy {
    fail('It is a configuration error to specify both allow_update and update_policy at the same time.')
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
      replace => $replace_file,
      notify  => Class['dns::service'],
    }
  }
}

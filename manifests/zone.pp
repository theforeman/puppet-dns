# Define new zone for the dns
define dns::zone (
    Array[String] $target_views                         = [],
    String $zonetype                                    = 'master',
    String $soa                                         = $::fqdn,
    Boolean $reverse                                    = false,
    String $ttl                                         = '10800',
    Stdlib::Compat::Ip_address $soaip                   = $::ipaddress,
    Integer $refresh                                    = 86400,
    Integer $update_retry                               = 3600,
    Integer $expire                                     = 604800,
    Integer $negttl                                     = 3600,
    Integer $serial                                     = 1,
    Array $masters                                      = [],
    Array $allow_transfer                               = [],
    Array $allow_query                                  = [],
    Array $also_notify                                  = [],
    String $zone                                        = $title,
    Optional[String] $contact                           = undef,
    Stdlib::Absolutepath $zonefilepath                  = $::dns::zonefilepath,
    String $filename                                    = "db.${title}",
    Boolean $manage_file                                = true,
    Enum['first', 'only'] $forward                      = 'first',
    Array $forwarders                                   = [],
    Optional[Enum['yes', 'no', 'explicit']] $dns_notify = undef,
) {

  $_contact = pick($contact, "root.${zone}.")

  $zonefilename = "${zonefilepath}/${filename}"

  if $::dns::enable_views {
    if $target_views == undef or size($target_views) == 0 {
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

  create_viewzones($_target_views)

  if $manage_file and !defined(File[$zonefilename]) {
    file { $zonefilename:
      ensure  => file,
      owner   => $dns::user,
      group   => $dns::group,
      mode    => '0644',
      content => template('dns/zone.header.erb'),
      replace => false,
      notify  => Service[$::dns::namedservicename],
    }
  }
}

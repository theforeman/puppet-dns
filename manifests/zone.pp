# Define new zone for the dns
define dns::zone (
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
    String $contact                                     = "root.${title}.",
    Stdlib::Absolutepath $zonefilepath                  = $::dns::zonefilepath,
    String $filename                                    = "db.${title}",
    Boolean $manage_file                                = true,
    Enum['first', 'only'] $forward                      = 'first',
    Array $forwarders                                   = [],
    Optional[Enum['yes', 'no', 'explicit']] $dns_notify = undef,
) {

  $zonefilename = "${zonefilepath}/${filename}"

  if $zonetype == 'slave' {
    $_dns_notify = pick($dns_notify, 'no')
  } else {
    $_dns_notify = $dns_notify
  }

  concat::fragment { "dns_zones+10_${zone}.dns":
    target  => $::dns::publicviewpath,
    content => template('dns/named.zone.erb'),
    order   => "10-${zone}",
  }

  if $manage_file {
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

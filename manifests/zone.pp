define dns::zone (
    $zonetype='master',
    $soa='',
    $reverse=false,
    $ttl='10800',
    $soaip='',
    $refresh = 86400,
    $update_retry = 3600,
    $expire = 604800,
    $negttl = 3600
) {
  $contact = "root.${name}"
  $serial = 1

  include dns
  include dns::params

  $zone             = $name
  $filename         = "db.${zone}"
  $dnsdir           = $dns::params::dnsdir
  $zonefilename     = "${dns::params::zonefilepath}/${filename}"
  $publicviewpath   = $dns::params::publicviewpath
  $zonefilepath     = $dns::params::zonefilepath
  $vardir           = $dns::params::vardir
  $namedservicename = $dns::params::namedservicename

  concat_fragment { "dns_zones+10_${zone}.dns":
    content => template('dns/named.zone.erb'),
  }

  file { $zonefilename:
    content => template('dns/zone.header.erb'),
    require => File[$dns::params::zonefilepath],
    replace => false,
    notify  => Service[$dns::params::namedservicename],
  }
}

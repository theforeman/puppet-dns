define dns::zone ($zonetype='master', $soa, $reverse='false', $ttl='10800', $soaip) {
  $contact = "root@${name}"
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

  concat_build { "zonefile_${zone}":
    order  => ['*.zone'],
    target => "${vardir}/puppetstore/${filename}",
  }

  concat_fragment { "dns_zones+10_${zone}.dns":
    content => template('dns/named.zone.erb'),
    notify  => Service[$namedservicename],
  }
  concat_fragment { "zonefile_${zone}+05_${zone}.zone":
    content => template('dns/zone.header.erb'),
    notify  => Service[$namedservicename],
  }

  exec { "create-zone_${zone}":
    command => "/bin/cp puppetstore/${filename} zones/${filename}",
    cwd     => $vardir,
    creates => "${vardir}/zones/${filename}",
    notify  => Service[$namedservicename],
  }

}

define dns::zone ($zonetype="master",$soa,$reverse="false",$ttl="10800",$soaip){
  $contact = "root@${name}"
  $serial = 1
  include dns
  include dns::params

  $zone = $name
  $filename = "db.${zone}"
  $dnsdir = $dns::params::dnsdir
  $zonefilename = "${dns::params::zonefilepath}/${filename}"
  $publicviewpath = $dns::params::publicviewpath
  $zonefilepath = $dns::params::zonefilepath
  $vardir = $dns::params::vardir
  $namedservicename = $dns::params::namedservicename

  include concat::setup

  concat { "${vardir}/puppetstore/${filename}": }

  concat::fragment {
    "dns_zone_${zone}": # this sets the named zones config
      target => "$publicviewpath",
      notify => Service["$namedservicename"],
      content => template("dns/named.zone.erb");
    "dns_zonefile_${zone}": # build zonefile header
      order => "05",
      target => "${vardir}/puppetstore/${filename}",
      notify => Service["$namedservicename"],
      content => template("dns/zone.header.erb");
  }

  exec { "create-zone_${zone}":
    command => "/bin/cp puppetstore/${filename} zones/${filename}",
    cwd     => "${vardir}",
    creates => "${vardir}/zones/${filename}",
  }

}


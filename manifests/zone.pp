# Define new zone for the dns
define dns::zone (
    $zonetype       = 'master',
    $soa            = $::fqdn,
    $reverse        = false,
    $ttl            = '10800',
    $soaip          = $::ipaddress,
    $refresh        = 86400,
    $update_retry   = 3600,
    $expire         = 604800,
    $negttl         = 3600,
    $serial         = 1,
    $masters        = [],
    $allow_transfer = [],
    $zone           = $title,
    $contact        = "root.${title}.",
    $zonefilepath   = $::dns::zonefilepath,
    $filename       = "db.${title}",
    $static_records = false,
) {

  validate_bool($reverse, $static_records)
  validate_array($masters, $allow_transfer)

  $zonefilename = "${zonefilepath}/${filename}"

  concat_fragment { "dns_zones+10_${zone}.dns":
    content => template('dns/named.zone.erb'),
  }

  file { $zonefilename:
    ensure  => file,
    owner   => $dns::user,
    group   => $dns::group,
    mode    => '0644',
    content => template('dns/zone.header.erb'),
    replace => false,
    notify  => Service[$::dns::namedservicename],
  }

  if $static_records {
    concat_fragment { "dns-static-${zone}+01header.dnsstatic":
      content => "; static file for ${zone}",
    }
  
    Dns::Record <<| |>> { notify => Concat_build["dns-static-${zone}"] }
  
    concat_build { "dns-static-${zone}":
      order  => [ '*.dnsstatic' ],
      notify => [
        Service[$::dns::namedservicename],
        File[ "${zonefilename}.static"],
      ],
    }
  
    file { "${zonefilename}.static":
      ensure  => file,
      owner   => $dns::user,
      group   => $dns::group,
      mode    => '0644',
      notify  => Service[$::dns::namedservicename],
      source  => concat_output("dns-static-${zone}"),
      require => Concat_build[ "dns-static-${zone}"],
    }
  }

}

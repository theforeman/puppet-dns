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
) {

  validate_bool($reverse)
  validate_array($masters, $allow_transfer)

  # Validate that the value for soa is within the zone
  $soa_parts    = split($soa, '[.]')
  $soa_hostname = $soa_parts[0]
  if $soa != "${soa_hostname}.${zone}" and ! $reverse {
    fail('soa must be within the defined zone.')
  }

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
}

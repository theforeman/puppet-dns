# Define new zone for the dns
define dns::zone (
    $target_views   = [],
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
    $allow_query    = [],
    $also_notify    = [],
    $zone           = $title,
    $contact        = undef,
    $zonefilepath   = $::dns::zonefilepath,
    $filename       = "db.${title}",
    $manage_file    = true,
    $forward        = 'first',
    $forwarders     = [],
    $dns_notify     = undef,
) {

  validate_bool($reverse, $manage_file)
  validate_array($masters, $allow_transfer, $allow_query, $forwarders, $also_notify, $target_views)
  validate_re($forward, '^(first|only)$', 'Only \'first\' or \'only\' are valid values for forward field')
  if $dns_notify {
    validate_re($dns_notify, '^(yes|no|explicit)$', 'Only \'yes\', \'no\', or \'explicit\' are valid values for dns_notify field')
  }

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

  if $manage_file {
    unless defined(File[$zonefilename]) {
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
}

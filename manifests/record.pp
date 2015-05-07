# Define new DNS record
define dns::record (
  $zone     = undef,
  $label    = undef,
  $target   = undef,
  $type     = undef,
  $priority = undef,
  $weight   = undef,
  $port     = undef,
  $comment  = ' ',
) {

  if $target == undef {
    fail("Failed to define target for record ${title}")
  }
  else {
    validate_string($target)
  }

  if $type == undef {
    fail("Failed to define record type for record ${title}")
  }
  else {
    validate_string($type)
    $dnstype = upcase($type)
  }

  # if you choose not to override the label or zone attributes  (if you use the
  # FQDN of the record you want to create, you shouldn't need to), we will 
  # generate these attributes from the FQDN.
  if ($label == undef) or ($zone == undef) {
    $domain_array = split($title, '[.]' )
    $_label = $domain_array[0]
    $_zone = join(delete_at($domain_array, 0), '.')
  } else {
    $_label = $label
    $_zone = $zone
  }
  
  if $dnstype =~ /(CNAME|TXT|A|PTR)/ {
    $line = "${_label} IN ${dnstype} ${target}  ; ${comment}"
  }
  elsif $dnstype == 'MX' {
    validate_integer($priority, 65535, 0)
    $line = "${_label} IN ${dnstype} ${priority} ${target}  ; ${comment}"
  }
  elsif $dnstype == 'SRV' {
    validate_integer($priority, 65535, 0)
    validate_integer($weight, 65535, 0)
    validate_integer($port, 65535, 0)
    $line = "${_label} IN ${dnstype} ${priority} ${weight} ${port} ${target}  ; ${comment}"
  }
  else {
    fail("Incorrect DNS record type specified for record ${title}")
  }

  concat_fragment { "dns-static-${_zone}+02content-${title}.dnsstatic":
    content => $line,
  }

}

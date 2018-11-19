# Generate a new key for the dns
#
# === Parameters:
#
# $secret::                     This is the secret to be place inside the keyfile, if left empty the key will be generated
#
define dns::key(
  String               $algorithm    = 'hmac-md5',
  String               $filename     = "${name}.key",
  Optional[String]     $secret       = undef,
  Stdlib::Absolutepath $keydir       = $dns::dnsdir,
  Integer              $keysize      = 512,
) {
  $keyfilename = "${keydir}/${filename}"

  if $secret {
    file {$keyfilename:
      ensure  => file,
      owner   => $dns::user,
      group   => $dns::group,
      mode    => '0640',
      content => template('dns/key.erb'),
      notify  => Service[$dns::namedservicename],
    }
  } else {
    exec { "create-${filename}":
      command => "${dns::rndcconfgen} -r /dev/urandom -a -c ${keyfilename} -b ${keysize} -k ${name}",
      creates => $keyfilename,
      notify  => Service[$dns::namedservicename],
    }-> file { $keyfilename:
      owner => 'root',
      group => $dns::params::group,
      mode  => '0640',
    }
  }

  concat::fragment { "named.conf+20-key-${name}.dns":
    target  => $dns::namedconf_path,
    content => "include \"${keyfilename}\";\n",
    order   => '20',
  }
}

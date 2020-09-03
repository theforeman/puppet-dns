# Generate a new key for the dns
#
# @param algorithm
#   The algorithm used to generate the secret key
#
# @param filename
#   The filename to store the key. This is placed in the key directory.
#
# @param secret
#   This is the secret to be place inside the keyfile, if left empty the key
#   will be generated
#
# @param keydir
#   The directory to store the key in. Inherited from the main dns class by default.
#
# @param keysize
#   The size of the key to generate. Only used when generating the key. It's
#   ignored if when a key is specified.
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
      before  => Class['dns::config'],
      notify  => Class['dns::service'],
    }
  } else {
    exec { "create-${filename}":
      command => "${dns::rndcconfgen} -r /dev/urandom -a -c ${keyfilename} -b ${keysize} -k ${name}",
      creates => $keyfilename,
      before  => Class['dns::config'],
      notify  => Class['dns::service'],
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

class dns {
    include dns::params

    $namedconf_path = $dns::params::namedconf_path
    $dnsdir = $dns::params::dnsdir
    $dns_server_package = $dns::params::dns_server_package
    $rndckeypath = $dns::params::rndckeypath
    $rndc_alg = $dns::params::rndc_alg
    $rndc_secret = $dns::params::rndc_secret
    $optionspath = $dns::params::optionspath
    $publicviewpath = $dns::params::publicviewpath
    $vardir = $dns::params::vardir
    $namedservicename = $dns::params::namedservicename
    $zonefilepath = $dns::params::zonefilepath

    package { 'dns':
      ensure => installed,
      name   => $dns_server_package,
    }

    File {
        require => Package['dns'],
    }

    file {
        $namedconf_path:
            owner   => root,
            group   => $dns::params::group,
            mode    => '0640',
            require => Package['dns'],
            content => template('dns/named.conf.erb');
        $optionspath:
            owner   => root,
            group   => $dns::params::group,
            mode    => '0640',
            content => template('dns/options.conf.erb');
        $zonefilepath:
            ensure  => directory,
            owner   => $dns::params::user,
            group   => $dns::params::group,
            mode    => '0640';
        "${vardir}/puppetstore":
            ensure  => directory,
            group   => $dns::params::group,
            mode    => '0640';
    }

    concat_build { 'dns_zones':
      order  => ['*.dns'],
      target => $publicviewpath,
      notify => Service[$namedservicename],
    }

    concat_fragment { 'dns_zones+01-header.dns':
      content => ' ',
    }

    service {
        $namedservicename:
            ensure     => running,
            enable     => true,
            hasstatus  => true,
            hasrestart => true,
            require    => Package['dns'];
    }

    exec { 'create-rndc.key':
      command => "/usr/sbin/rndc-confgen -r /dev/urandom -a -c ${rndckeypath}",
      cwd     => '/tmp',
      creates => $rndckeypath,
    }

    file { $rndckeypath:
      owner   => 'root',
      group   => $dns::params::group,
      mode    => '0640',
      require => Exec['create-rndc.key'],
    }
}

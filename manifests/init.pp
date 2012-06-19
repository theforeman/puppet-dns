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
    $publicview = $dns::params::publicview
    $vardir = $dns::params::vardir
    $namedservicename = $dns::params::namedservicename
    $zonefilepath = $dns::params::zonefilepath

    package { 'dns':
      ensure => installed,
      name   => $dns_server_package,
    }

    file {
        $namedconf_path:
            owner   => root,
            group   => 0,
            mode    => '0644',
            require => Package['dns'],
            content => template('dns/named.conf.erb');
        $dnsdir:
            ensure  => directory,
            owner   => root,
            group   => 0,
            mode    => '0755';
        $vardir:
            ensure  => directory,
            owner   => $dns::params::user,
            group   => $dns::params::user,
            recurse => true,
            mode    => '0755';
        $optionspath:
            owner   => root,
            group   => 0,
            mode    => '0644',
            content => template('dns/options.conf.erb');
        "${vardir}/named.ca":
            owner   => $dns::params::user,
            group   => $dns::params::user,
            mode    => '0644',
            source  => 'puppet:///modules/dns/named.ca';
        "${vardir}/named.local":
            owner   => $dns::params::user,
            group   => $dns::params::user,
            mode    => '0644',
            source  => 'puppet:///modules/dns/named.local';
        "${vardir}/localhost.zone":
            owner   => $dns::params::user,
            group   => $dns::params::user,
            mode    => '0644',
            source  => 'puppet:///modules/dns/localhost.zone';
        $zonefilepath:
            ensure  => directory,
            owner   => $dns::params::user,
            group   => $dns::params::user,
            mode    => '0755';
    }

    concat_build { 'dns_zones':
      order  => ['*.dns'],
      target => $publicviewpath,
      notify => Service[$namedservicename],
    }

    concat_fragment { "dns_zones+05_${zone}.dns":
      content => template('dns/publicView.conf-header.erb'),
    }

    service {
        $namedservicename:
            ensure     => running,
            enable     => true,
            hasstatus  => true,
            hasrestart => true,
            require    => Package['dns'];
    }

    file { "${vardir}/puppetstore": ensure => directory }

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

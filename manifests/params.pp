# Default parameters
# @api private
class dns::params inherits dns::globals {
  case $facts['os']['family'] {
    'Debian': {
      $dnsdir             = '/etc/bind'
      $vardir             = '/var/cache/bind'
      $optionspath        = "${dnsdir}/named.conf.options"
      $zonefilepath       = "${vardir}/zones"
      $localzonepath      = "${dnsdir}/zones.rfc1918"
      $defaultzonepath    = "${dnsdir}/named.conf.default-zones"
      $publicviewpath     = "${dnsdir}/zones.conf"
      $viewconfigpath     = "${dnsdir}/views"
      $dns_server_package = 'bind9'
      $namedservicename   = 'bind9'
      $user               = 'bind'
      $group              = 'bind'
      $rndcconfgen        = '/usr/sbin/rndc-confgen'
      $named_checkconf    = '/usr/sbin/named-checkconf'
      $sysconfig_file     = '/etc/default/bind9'
      $sysconfig_template = "dns/sysconfig.${facts['os']['family']}.erb"
      $sysconfig_startup_options = '-u bind'
      $sysconfig_resolvconf_integration = false

      # This option is not relevant for Debian
      $sysconfig_disable_zone_checking = undef

      $dnssec_enable = $facts['os']['name'] ? {
        'Debian' => if versioncmp($facts['os']['release']['major'], '11') >= 0 { undef } else { 'yes' },
        'Ubuntu' => if versioncmp($facts['os']['release']['major'], '20.04') >= 0 { undef } else { 'yes' },
        default  => undef,
      }
    }
    'RedHat': {
      $user = 'named'
      $group = 'named'

      $sysconfig_template = "dns/sysconfig.${facts['os']['family']}.erb"
      $sysconfig_startup_options = undef
      $sysconfig_disable_zone_checking = undef

      # This option is not relevant for RedHat
      $sysconfig_resolvconf_integration = undef

      if $dns::globals::scl {
        $sclprovider = $dns::globals::scl.split('-')[0]
        $sclenvname = $dns::globals::scl
        $sclroot = "/opt/${sclprovider}/${sclenvname}/root"
        $sclvar = "/var/opt/${sclprovider}/scls/${sclenvname}"
        $sclconfroot = "/etc/opt/${sclprovider}/scls/${sclenvname}"

        $dnsdir = $sclconfroot
        $vardir = "${sclvar}/named/data"
        $optionspath = "${dnsdir}/options.conf"
        $zonefilepath = "${vardir}/dynamic"
        $localzonepath = "${dnsdir}/named.rfc1912.zones"
        $defaultzonepath = 'unmanaged'
        $publicviewpath = "${dnsdir}/zones.conf"
        $viewconfigpath = "${dnsdir}/views"
        # Install the SCL meta package to pull in utils
        $dns_server_package = $sclenvname
        $namedservicename = "${sclenvname}-named.service"

        $rndcconfgen = "${sclroot}/usr/sbin/rndc-confgen"
        $named_checkconf = "${sclroot}/usr/bin/named-checkconf"
        $sysconfig_file = "${sclconfroot}/sysconfig/named"

        # option not available on bind > 9-18
        $dnssec_enable = undef
      }
      else {
        $dnsdir = '/etc'
        $vardir = '/var/named'
        $optionspath = '/etc/named/options.conf'
        $zonefilepath = "${vardir}/dynamic"
        $localzonepath = "${dnsdir}/named.rfc1912.zones"
        $defaultzonepath = 'unmanaged'
        $publicviewpath = "${dnsdir}/named/zones.conf"
        $viewconfigpath = "${dnsdir}/named/views"
        $dns_server_package = 'bind'
        $namedservicename = 'named'

        $rndcconfgen = '/usr/sbin/rndc-confgen'
        $named_checkconf = '/usr/sbin/named-checkconf'
        $sysconfig_file = '/etc/sysconfig/named'
        $dnssec_enable = if versioncmp($facts['os']['release']['major'], '9') >= 0 { undef } else { 'yes' }
      }
    }
    /^(FreeBSD|DragonFly)$/: {
      $dnsdir             = '/usr/local/etc/namedb'
      $vardir             = '/usr/local/etc/namedb/working'
      $optionspath        = '/usr/local/etc/namedb/options.conf'
      $zonefilepath       = "${dnsdir}/dynamic"
      $localzonepath      = 'unmanaged' # "${dnsdir}/master/empty.db"
      $defaultzonepath    = 'unmanaged'
      $publicviewpath     = "${dnsdir}/zones.conf"
      $viewconfigpath     = "${dnsdir}/named/views"
      $dns_server_package = 'bind916'
      $namedservicename   = 'named'
      $user               = 'bind'
      $group              = 'bind'
      $rndcconfgen        = '/usr/local/sbin/rndc-confgen'
      $named_checkconf    = '/usr/local/sbin/named-checkconf'
      # The sysconfig settings are not relevant for FreeBSD
      $sysconfig_file     = undef
      $sysconfig_template = undef
      $sysconfig_startup_options = undef
      $sysconfig_disable_zone_checking = undef
      $sysconfig_resolvconf_integration = undef
      $dnssec_enable = undef
    }
    'Archlinux': {
      $dnsdir             = '/etc'
      $vardir             = '/var/named'
      $optionspath        = "${dnsdir}/named.options.conf"
      $zonefilepath       = "${vardir}/dynamic"
      $localzonepath      = 'unmanaged' # "${dnsdir}/named.local.conf"
      $defaultzonepath    = 'unmanaged'
      $publicviewpath     = "${dnsdir}/zones.conf"
      $viewconfigpath     = "${dnsdir}/views"
      $dns_server_package = 'bind'
      $namedservicename   = 'named'
      $user               = 'named'
      $group              = 'named'
      $rndcconfgen        = '/usr/sbin/rndc-confgen'
      $named_checkconf    = '/usr/sbin/named-checkconf'
      # The sysconfig settings are not relevant for ArchLinux
      $sysconfig_file     = undef
      $sysconfig_template = undef
      $sysconfig_startup_options = undef
      $sysconfig_disable_zone_checking = undef
      $sysconfig_resolvconf_integration = undef

      $dnssec_enable = undef
    }
    default: {
      fail ("Unsupported operating system family ${facts['os']['family']}")
    }
  }

  $namedconf_path        = "${dnsdir}/named.conf"

  #pertaining to rndc
  $rndckeypath           = "${dnsdir}/rndc.key"

  $controls              = {
    '127.0.0.1' => {
      'port' => 953,
      'allowed_addresses' => ['127.0.0.1'],
      'keys' => ['rndc-key'],
    },
  }
}

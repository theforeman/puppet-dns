# Default parameters
# @api private
class dns::params {
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
    }
    'RedHat': {
      $dnsdir             = '/etc'
      $vardir             = '/var/named'
      $optionspath        = '/etc/named/options.conf'
      $zonefilepath       = "${vardir}/dynamic"
      $localzonepath      = "${dnsdir}/named.rfc1912.zones"
      $defaultzonepath    = 'unmanaged'
      $publicviewpath     = "${dnsdir}/named/zones.conf"
      $viewconfigpath     = "${dnsdir}/named/views"
      $dns_server_package = 'bind'
      $namedservicename   = 'named'
      $user               = 'named'
      $group              = 'named'
      $rndcconfgen        = '/usr/sbin/rndc-confgen'
      $named_checkconf    = '/usr/sbin/named-checkconf'
      $sysconfig_file     = '/etc/sysconfig/named'
      $sysconfig_template = "dns/sysconfig.${facts['os']['family']}.erb"
      $sysconfig_startup_options = undef
      $sysconfig_disable_zone_checking = undef

      # This option is not relevant for RedHat
      $sysconfig_resolvconf_integration = undef
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
      $dns_server_package = 'bind910'
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
    }
    default: {
      fail ("Unsupported operating system family ${facts['os']['family']}")
    }
  }

  # This module will manage the system group by default
  $group_manage = true

  # Don't set any restart command by default, let Puppet use the
  # platform-dependent service resource default when handling the service
  # restart.
  $service_restart_command = undef

  $namedconf_template    = 'dns/named.conf.erb'
  $optionsconf_template  = 'dns/options.conf.erb'

  $sysconfig_additional_settings = {}

  $namedconf_path        = "${dnsdir}/named.conf"

  #pertaining to rndc
  $rndckeypath           = "${dnsdir}/rndc.key"

  $enable_views          = false

  $forward               = undef
  $forwarders            = []

  $listen_on_v6          = 'any'

  $recursion             = 'yes'
  $allow_recursion       = [ 'localnets', 'localhost' ]
  $allow_query           = [ 'any' ]

  $empty_zones_enable    = 'yes'

  $dns_notify            = undef

  $dnssec_enable         = 'yes'
  $dnssec_validation     = 'yes'

  $controls              = {
    '127.0.0.1' => {
      'port' => 953,
      'allowed_addresses' => [ '127.0.0.1' ],
      'keys' => [ 'rndc-key' ],
    },
  }

  $manage_service        = true
  $service_ensure        = 'running'
  $service_enable        = true
  $acls                  = {}

  $additional_options    = {}
  $additional_directives = []

  $zones                 = {}
  $keys                  = {}
}

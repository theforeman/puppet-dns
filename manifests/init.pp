# Manage an ISC BIND nameserver
#
# @param namedconf_path
#   Path of the named config
# @param dnsdir
#   Directory holding the named configs
# @param dns_server_package
#   Name of the package to install
# @param rndckeypath
#   Path of the RNDC key
# @param optionspath
#   Path of the named options
# @param publicviewpath
#   Path of the config file holding all the zones
# @param vardir
#   Directory holding the variable or working files
# @param group_manage
#   Should this module manage the Unix system group under which BIND runs (see
#   dns::params)?  Defaults to true. Set to false if you want to manage the
#   system group yourself.
# @param manage_service
#   Should this module manage the dns service?
#   This only applies to the service management (running, stopped) and not to
#   whether the service should be installed or not.
#   IMPORTANT: this will not reload the service after a config change, you'll
#   have to do that manually or via a separate call to notify
# @param namedservicename
#   Name of the service
# @param zonefilepath
#   Directory containing zone files
# @param localzonepath
#   File holding local zones like RFC1912 or RFC1918 files.  The special value
#   'unmanaged' can be used if one plans to create custom RFC1912/RFC1918 zones
#   via dns, where the inclusion of package-shipped zone files is not desired.
# @param defaultzonepath
#   File holding some RFC1912 zone includes on systems like Debian.
#   The special value 'unmanaged' can be used if one plans to create custom
#   zones via dns, where the inclusion of package-shipped zone files is not
#   desired.
# @param forward
#   The forward option
# @param forwarders
#   The forwarders option
# @param listen_on_v6
#   The listen-on-v6 option
# @param recursion
#   The recursion option
# @param allow_recursion
#   The allow-recursion option
# @param allow_query
#   The allow-query option
# @param empty_zones_enable
#   The empty-zones-enable option
# @param dns_notify
#   The notify option in named.conf
# @param dnssec_enable
#   The dnssec-enable option
# @param dnssec_validation
#   The dnssec-validation option
# @param namedconf_template
#   The template to be used for named.conf
# @param acls
#   Specify a hash of ACLs. Each key is the name of a network, and its value is
#   an array of subnet strings.
# @param optionsconf_template
#   The template to be used for options.conf
# @param sysconfig_file
#   Path to the sysconfig or default file used to set startup options for
#   named. Under Debian this is /etc/default/bind9, under RedHat this is
#   /etc/sysconfig/named. FreeBSD/DragonFly and ArchLinux do not feature such
#   files, thus the sysconfig parameters are not relevant for these operating
#   systems.
# @param sysconfig_template
#   The template used to model /etc/default/bind9 or /etc/sysconfig/named.
#   Default is "dns/sysconfig.${facts[osfamily]}.erb" for Debian and RedHat,
#   and undef for others.
# @param sysconfig_startup_options
#   Startup options for the `named` process, rendered as the `OPTIONS` string
#   in the sysconfig file (see above). Use this to set commandline flags and
#   options for `named`. For example, to use IPv4 only and disable IPv6 support
#   in named on Debian set this parameter to `-u bind -4`. The default value
#   depends on the underlying OS.
# @param sysconfig_resolvconf_integration
#   Should named integrate with resolvconf upon startup? Default is false, and
#   this only pertains to the Debian OS family.
# @param sysconfig_disable_zone_checking
#   Should zone checking be disabled upon named startup? Default is undef, and
#   this only pertains to the RedHat OS family.
# @param sysconfig_additional_settings
#   Additional settings to add to the sysconfig file. This is a simple hash of
#   key-value strings that will be rendered as `KEY="value"` in the sysconfig
#   file. Use this to add custom (environment) variables relevant for named.
#   Default is empty.
# @param controls
#   Specify a hash of controls. Each key is the name of a network, and its
#   value is a hash containing 'port' => integer, 'keys' => array and
#   'allowed_addresses' => array
# @param service_ensure
#   The ensure attribute on the service
# @param service_enable
#   Whether to enable the service (start at boot)
# @param service_restart_command
#   Custom command to use when the service will be restarted (notified by
#   configuration changes). Will be passed directly to the restart parameter of
#   the contained service resource. This is useful when you want BIND to reload
#   its configuration instead of restarting the whole process, for example by
#   setting `service_restart_command` to `/usr/sbin/service bind9 reload` or
#   `/usr/sbin/rndc reload` or even `/usr/bin/systemctl try-reload-or-restart bind9`.
#   Default is 'undef' so the service resource default is used.
# @param additional_options
#   Additional options
# @param additional_directives
#   Additional directives. These are free form strings that allow for full
#   customization. Use with caution.
# @param enable_views
#   Flag to indicate bind views support. Will remove global zone configuration
#   like localzonepath inclusion.
# @param zones
#   A hash of zones to be created. See dns::zone for options.
# @param keys
#   A hash of keys to be created. See dns::key for options.
#
# @see dns::zone
# @see dns::key
class dns (
  Stdlib::Absolutepath $namedconf_path                              = $dns::params::namedconf_path,
  Stdlib::Absolutepath $dnsdir                                      = $dns::params::dnsdir,
  String $dns_server_package                                        = $dns::params::dns_server_package,
  Stdlib::Absolutepath $rndckeypath                                 = $dns::params::rndckeypath,
  Stdlib::Absolutepath $optionspath                                 = $dns::params::optionspath,
  Stdlib::Absolutepath $publicviewpath                              = $dns::params::publicviewpath,
  Stdlib::Absolutepath $vardir                                      = $dns::params::vardir,
  Boolean $group_manage                                             = $dns::params::group_manage,
  Boolean $manage_service                                           = $dns::params::manage_service,
  String $namedservicename                                          = $dns::params::namedservicename,
  Stdlib::Absolutepath $zonefilepath                                = $dns::params::zonefilepath,
  Variant[Enum['unmanaged'], Stdlib::Absolutepath] $localzonepath   = $dns::params::localzonepath,
  Variant[Enum['unmanaged'], Stdlib::Absolutepath] $defaultzonepath = $dns::params::defaultzonepath,
  Optional[Enum['only', 'first']] $forward                          = $dns::params::forward,
  Array[String] $forwarders                                         = $dns::params::forwarders,
  Optional[Variant[String, Boolean]] $listen_on_v6                  = $dns::params::listen_on_v6,
  Enum['yes', 'no'] $recursion                                      = $dns::params::recursion,
  Array[String] $allow_recursion                                    = $dns::params::allow_recursion,
  Array[String] $allow_query                                        = $dns::params::allow_query,
  Enum[yes, no] $empty_zones_enable                                 = $dns::params::empty_zones_enable,
  Optional[Enum['yes', 'no', 'explicit']] $dns_notify               = $dns::params::dns_notify,
  Enum['yes', 'no'] $dnssec_enable                                  = $dns::params::dnssec_enable,
  Enum['yes', 'no', 'auto'] $dnssec_validation                      = $dns::params::dnssec_validation,
  String $namedconf_template                                        = $dns::params::namedconf_template,
  Hash[String, Array[String]] $acls                                 = $dns::params::acls,
  String $optionsconf_template                                      = $dns::params::optionsconf_template,
  Optional[Stdlib::Absolutepath] $sysconfig_file                    = $dns::params::sysconfig_file,
  Optional[String] $sysconfig_template                              = $dns::params::sysconfig_template,
  Optional[String] $sysconfig_startup_options                       = $dns::params::sysconfig_startup_options,
  Optional[Boolean] $sysconfig_resolvconf_integration               = $dns::params::sysconfig_resolvconf_integration,
  Optional[Boolean] $sysconfig_disable_zone_checking                = $dns::params::sysconfig_disable_zone_checking,
  Optional[Hash[String[1], String]] $sysconfig_additional_settings  = $dns::params::sysconfig_additional_settings,
  Hash[String, Hash[String, Data]] $controls                        = $dns::params::controls,
  Variant[Enum['running', 'stopped'], Boolean] $service_ensure      = $dns::params::service_ensure,
  Boolean $service_enable                                           = $dns::params::service_enable,
  Optional[String[1]] $service_restart_command                      = $dns::params::service_restart_command,
  Hash[String, Data] $additional_options                            = $dns::params::additional_options,
  Array[String] $additional_directives                              = $dns::params::additional_directives,
  Boolean $enable_views                                             = $dns::params::enable_views,
  Hash[String, Hash] $zones                                         = $dns::params::zones,
  Hash[String, Hash] $keys                                          = $dns::params::keys,
) inherits dns::params {

  include dns::install
  include dns::config
  contain dns::service

  Class['dns::install'] ~> Class['dns::config'] ~> Class['dns::service']

  create_resources('dns::key', $keys)
  create_resources('dns::zone', $zones)
}

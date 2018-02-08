# == Class: dns
#
# Install, configure and start dns service
#
# === Parameters:
# $namedconf_path::             Path of the named config
#
# $dnsdir::                     Directory holding the named configs
#
# $dns_server_package::         Name of the package to install
#
# $rndckeypath::                Path of the RNDC key
#
# $optionspath::                Path of the named options
#
# $publicviewpath::             Path of the config file holding all the zones
#
# $vardir::                     Directory holding the variable or working files
#
# $namedservicename::           Name of the service
#
# $zonefilepath::               Directory containing zone files
#
# $localzonepath::              File holding local zones like RFC1912 or RFC1918 files.
#                               The special value 'unmanaged' can be used if one plans
#                               to create custom RFC1912/RFC1918 zones via ::dns,
#                               where the inclusion of package-shipped zone files is
#                               not desired.
#
# $defaultzonepath::            File holding some RFC1912 zone includes on systems
#                               like Debian.
#                               The special value 'unmanaged' can be used if one plans
#                               to create custom zones via ::dns,
#                               where the inclusion of package-shipped zone files is
#                               not desired.
#
# $forward::                    The forward option
#
# $forwarders::                 The forwarders option
#
# $listen_on_v6::               The listen-on-v6 option
#
# $recursion::                  The recursion option
#
# $allow_recursion::            The allow-recursion option
#
# $allow_query::                The allow-query option
#
# $empty_zones_enable::         The empty-zones-enable option
#
# $dns_notify::                 The notify option in named.conf
#
# $dnssec_enable::              The dnssec-enable option
#
# $dnssec_validation::          The dnssec-validation option
#
# $namedconf_template::         The template to be used for named.conf
#
# $acls::                       Specify a hash of ACLs. Each key is the
#                               name of a network, and its value is
#                               an array of subnet strings.
#
# $optionsconf_template::       The template to be used for options.conf
#
# $controls::                   Specify a hash of controls. Each key is the
#                               name of a network, and its value is a hash
#                               containing 'port' => integer, 'keys' => array
#                               and 'allowed_addresses' => array
#
# $service_ensure::             The ensure attribute on the service
#
# $service_enable::             Whether to enable the service (start at boot)
#
# $additional_options::         Additional options
#
# $additional_directives::      Additional directives. These are free form
#                               strings that allow for full customization. Use
#                               with caution.
#
# $enable_views::               Flag to indicate bind views support. Will remove
#                               global zone configuration like localzonepath
#                               inclusion.
#
# $zones::                      A hash of zones to be created. See dns::zone
#                               for options.
#
# $dns_update_key:              key to allow ddns updates of zones (mac-md5).   
# 
# === Usage:
#
# * Simple usage:
#
#     include dns
#
class dns (
  Stdlib::Absolutepath $namedconf_path                              = $::dns::params::namedconf_path,
  Stdlib::Absolutepath $dnsdir                                      = $::dns::params::dnsdir,
  String $dns_server_package                                        = $::dns::params::dns_server_package,
  Stdlib::Absolutepath $rndckeypath                                 = $::dns::params::rndckeypath,
  Stdlib::Absolutepath $optionspath                                 = $::dns::params::optionspath,
  Stdlib::Absolutepath $publicviewpath                              = $::dns::params::publicviewpath,
  Stdlib::Absolutepath $vardir                                      = $::dns::params::vardir,
  String $namedservicename                                          = $::dns::params::namedservicename,
  Stdlib::Absolutepath $zonefilepath                                = $::dns::params::zonefilepath,
  Variant[Enum['unmanaged'], Stdlib::Absolutepath] $localzonepath   = $::dns::params::localzonepath,
  Variant[Enum['unmanaged'], Stdlib::Absolutepath] $defaultzonepath = $::dns::params::defaultzonepath,
  Optional[Enum['only', 'first']] $forward                          = $::dns::params::forward,
  Array[String] $forwarders                                         = $::dns::params::forwarders,
  Optional[Variant[String, Boolean]] $listen_on_v6                  = $::dns::params::listen_on_v6,
  Enum['yes', 'no'] $recursion                                      = $::dns::params::recursion,
  Array[String] $allow_recursion                                    = $::dns::params::allow_recursion,
  Array[String] $allow_query                                        = $::dns::params::allow_query,
  Enum[yes, no] $empty_zones_enable                                 = $::dns::params::empty_zones_enable,
  Optional[Enum['yes', 'no', 'explicit']] $dns_notify               = $::dns::params::dns_notify,
  Enum['yes', 'no'] $dnssec_enable                                  = $::dns::params::dnssec_enable,
  Enum['yes', 'no', 'auto'] $dnssec_validation                      = $::dns::params::dnssec_validation,
  String $namedconf_template                                        = $::dns::params::namedconf_template,
  Hash[String, Array[String]] $acls                                 = $::dns::params::acls,
  String $optionsconf_template                                      = $::dns::params::optionsconf_template,
  Hash[String, Hash[String, Data]] $controls                        = $::dns::params::controls,
  Variant[Enum['running', 'stopped'], Boolean] $service_ensure      = $::dns::params::service_ensure,
  Boolean $service_enable                                           = $::dns::params::service_enable,
  Hash[String, Data] $additional_options                            = $::dns::params::additional_options,
  Array[String] $additional_directives                              = $::dns::params::additional_directives,
  Boolean $enable_views                                             = $::dns::params::enable_views,
  Hash[String, Hash] $zones                                         = $::dns::params::zones,
  Optional[String] $dns_update_key                                  = $::dns::params::dns_update_key
) inherits dns::params {

  include ::dns::install
  include ::dns::config
  contain ::dns::service

  Class['dns::install'] ~> Class['dns::config'] ~> Class['dns::service']

  create_resources('dns::zone', $zones)
}

# == Class: dns
#
# Install, configure and start dns service
#
# === Parameters:
# $namedconf_path::             Path of the named config
#                               type:Stdlib::Absolutepath
#
# $dnsdir::                     Directory holding the named configs
#                               type:Stdlib::Absolutepath
#
# $dns_server_package::         Name of the package to install
#                               type:String
#
# $rndckeypath::                Path of the RNDC key
#                               type:Stdlib::Absolutepath
#
# $optionspath::                Path of the named options
#                               type:Stdlib::Absolutepath
#
# $publicviewpath::             Path of the config file holding all the zones
#                               type:Stdlib::Absolutepath
#
# $vardir::                     Directory holding the variable or working files
#                               type:Stdlib::Absolutepath
#
# $namedservicename::           Name of the service
#                               type:String
#
# $zonefilepath::               Directory containing zone files
#                               type:Stdlib::Absolutepath
#
# $localzonepath::              File holding local zones like RFC1912 or RFC1918 files.
#                               type:Optional[Stdlib::Absolutepath]
#
# $defaultzonepath::            File holding default zone includes like db.local.
#                               type:Optional[Stdlib::Absolutepath]
#
# $forward::                    The forward option
#                               type:Optional[Enum['only', 'first']]
#
# $forwarders::                 The forwarders option
#                               type:Array[String]
#
# $listen_on_v6::               The listen-on-v6 option
#                               type:Optional[Variant[String, Boolean]]
#
# $recursion::                  The recursion option
#                               type:Enum[yes, no]
#
# $allow_recursion::            The allow-recursion option
#                               type:Array[String]
#
# $allow_query::                The allow-query option
#                               type:Array[String]
#
# $empty_zones_enable::         The empty-zones-enable option
#                               type:Enum[yes, no]
#
# $dns_notify::                 The notify option in named.conf
#                               type:Enum[yes, no, explicit]
#
# $dnssec_enable::              The dnssec-enable option
#                               type:Enum[yes, no]
#
# $dnssec_validation::          The dnssec-validation option
#                               type:Enum[yes, no, auto]
#
# $namedconf_template::         The template to be used for named.conf
#                               type:String
#
# $acls::                       Specify a hash of ACLs. Each key is the
#                               name of a network, and its value is
#                               an array of subnet strings.
#                               type:Hash[String, Array[String]]
#
# $optionsconf_template::       The template to be used for options.conf
#                               type:String
#
# $controls::                   Specify a hash of controls. Each key is the
#                               name of a network, and its value is a hash
#                               containing 'port' => integer, 'keys' => array
#                               and 'allowed_addresses' => array
#                               type:Hash[String, Hash[String, Data]]
#
# $service_ensure::             The ensure attribute on the service
#                               type:Enum[running, stopped]
#
# $service_enable::             Whether to enable the service (start at boot)
#                               type:Boolean
#
# $additional_options::         Additional options
#                               type:Hash[String, String]
#
# $additional_directives::      Additional directives. These are free form
#                               strings that allow for full customization. Use
#                               with caution.
#                               type:Array[String]
#
# $enable_views::               Flag to indicate bind views support. Will remove
#                               global zone configuration like localzonepath
#                               inclusion.
#                               type:Boolean
#
# === Usage:
#
# * Simple usage:
#
#     include dns
#
class dns (
  Stdlib::Absolutepath $namedconf_path                            = $::dns::params::namedconf_path,
  Stdlib::Absolutepath $dnsdir                                    = $::dns::params::dnsdir,
  String $dns_server_package                                      = $::dns::params::dns_server_package,
  Stdlib::Absolutepath $rndckeypath                               = $::dns::params::rndckeypath,
  Stdlib::Absolutepath $optionspath                               = $::dns::params::optionspath,
  Stdlib::Absolutepath $publicviewpath                            = $::dns::params::publicviewpath,
  Stdlib::Absolutepath $vardir                                    = $::dns::params::vardir,
  String $namedservicename                                        = $::dns::params::namedservicename,
  Stdlib::Absolutepath $zonefilepath                              = $::dns::params::zonefilepath,
  Optional[Stdlib::Absolutepath] $localzonepath                   = $::dns::params::localzonepath,
  Optional[Enum['only', 'first']] $forward                        = $::dns::params::forward,
  Array[String] $forwarders                                       = $::dns::params::forwarders,
  Optional[Variant[String, Boolean]] $listen_on_v6                = $::dns::params::listen_on_v6,
  Enum['yes', 'no'] $recursion                                    = $::dns::params::recursion,
  Array[String] $allow_recursion                                  = $::dns::params::allow_recursion,
  Array[String] $allow_query                                      = $::dns::params::allow_query,
  Enum[yes, no] $empty_zones_enable                               = $::dns::params::empty_zones_enable,
  Optional[Enum['yes', 'no', 'explicit']] $dns_notify             = $::dns::params::dns_notify,
  Enum['yes', 'no'] $dnssec_enable                                = $::dns::params::dnssec_enable,
  Enum['yes', 'no', 'auto'] $dnssec_validation                    = $::dns::params::dnssec_validation,
  String $namedconf_template                                      = $::dns::params::namedconf_template,
  Hash[String, Array[String]] $acls                               = $::dns::params::acls,
  String $optionsconf_template                                    = $::dns::params::optionsconf_template,
  Hash[String, Hash[String, Data]] $controls                      = $::dns::params::controls,
  Variant[Enum['running', 'stopped'], Boolean] $service_ensure    = $::dns::params::service_ensure,
  Boolean $service_enable                                         = $::dns::params::service_enable,
  Hash $additional_options                                        = $::dns::params::additional_options,
  Array $additional_directives                                    = $::dns::params::additional_directives,
  Boolean $enable_views                                           = $::dns::params::enable_views,
) inherits dns::params {

  class { '::dns::install': }
  ~> class { '::dns::config': }
  ~> class { '::dns::service': }
  ~> Class['dns']
}

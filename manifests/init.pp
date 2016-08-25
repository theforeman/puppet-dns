# == Class: dns
#
# Install, configure and start dns service
#
# === Parameters:
#
# $acls::                  Specify a hash of ACLs. Each key is the
#                          name of a network, and its value is
#                          an array of subnet strings.
#                          type:hash
#
# $controls::              Specify a hash of controls. Each key is the
#                          name of a network, and its value is a hash
#                          containing 'port' => integer, 'keys' => array
#                          and 'allowed_addresses' => array
#                          type:hash
#
# === Usage:
#
# * Simple usage:
#
#     include dns
#
class dns (
  $namedconf_path       = $::dns::params::namedconf_path,
  $dnsdir               = $::dns::params::dnsdir,
  $dns_server_package   = $::dns::params::dns_server_package,
  $rndckeypath          = $::dns::params::rndckeypath,
  $optionspath          = $::dns::params::optionspath,
  $publicviewpath       = $::dns::params::publicviewpath,
  $vardir               = $::dns::params::vardir,
  $namedservicename     = $::dns::params::namedservicename,
  $zonefilepath         = $::dns::params::zonefilepath,
  $localzonepath        = $::dns::params::localzonepath,
  $forward              = $::dns::params::forward,
  $forwarders           = $::dns::params::forwarders,
  $listen_on_v6         = $::dns::params::listen_on_v6,
  $recursion            = $::dns::params::recursion,
  $allow_recursion      = $::dns::params::allow_recursion,
  $allow_query          = $::dns::params::allow_query,
  $empty_zones_enable   = $::dns::params::empty_zones_enable,
  $dns_notify           = $::dns::params::dns_notify,
  $dnssec_enable        = $::dns::params::dnssec_enable,
  $dnssec_validation    = $::dns::params::dnssec_validation,
  $namedconf_template   = $::dns::params::namedconf_template,
  $acls                 = $::dns::params::acls,
  $optionsconf_template = $::dns::params::optionsconf_template,
  $controls             = $::dns::params::controls,
  $service_ensure       = $::dns::params::service_ensure,
  $service_enable       = $::dns::params::service_enable,
  $additional_options   = $::dns::params::additional_options,
) inherits dns::params {
  validate_array($dns::forwarders)
  validate_array($dns::allow_recursion)
  validate_array($dns::allow_query)
  validate_re($dns::recursion, '^(yes|no)$', 'Only \'yes\' and \'no\' are valid values for recursion field')
  validate_re($dns::dnssec_enable, '^(yes|no)$', 'Only \'yes\' and \'no\' are valid values for dnssec_enable field')
  validate_re($dns::dnssec_validation, '^(yes|no|auto)$', 'Only \'yes\', \'no\' and \'auto\' are valid values for dnssec_validation field')
  validate_re($dns::service_ensure, '^running|true|stopped|false$', 'Only \'running\', \'false\', \'stopped\' and \'false\' are validate values for service_ensure field')
  if $dns::forward {
    validate_re($dns::forward, '^(only|first)$', 'Only \'only\' and \'first\' are valid values for forward field')
  }
  if $dns::dns_notify {
    validate_re($dns_notify, '^(yes|no|explicit)$', 'Only \'yes\', \'no\', or \'explicit\' are valid values for dns_notify field')
  }
  validate_bool($dns::service_enable)
  validate_hash($controls)
  validate_hash($acls)
  validate_hash($additional_options)

  class { '::dns::install': } ~>
  class { '::dns::config': } ~>
  class { '::dns::service': } ->
  Class['dns']
}

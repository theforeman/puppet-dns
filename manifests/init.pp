# Install, configure and start dns service
class dns(
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
  $dnssec_enable        = $::dns::params::dnssec_enable,
  $dnssec_validation    = $::dns::params::dnssec_validation,
  $namedconf_template   = $::dns::params::namedconf_template,
  $optionsconf_template = $::dns::params::optionsconf_template,
  $service_ensure       = $::dns::params::service_ensure,
  $service_enable       = $::dns::params::service_enable,
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
  validate_bool($dns::service_enable)

  class { '::dns::install': } ~>
  class { '::dns::config': } ~>
  class { '::dns::service': } ->
  Class['dns']
}

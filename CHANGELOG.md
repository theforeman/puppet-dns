# Changelog

## 4.0.0

* Add Arch Linux support
* Fix README to state the module is under the Apache License 2.0, add full
  licence text
* Drop support for Ruby 1.8.7

## 3.4.1

* Do not configure listen-on-v6 parameter if it's not set

## 3.4.0

* Add additional_options parameter to dns class for options without parameters

## 3.3.1

* Skip package installation when dns_server_package is empty
* Nest 'forwarders' only if 'forward' is used
* Use concat fragments instead of file resource templates for config

## 3.3.0

* Add dns_notify to dns class and dns::zone define
* Add acls hash
* Add controls hash
* Change default path for zones.conf to /etc/named/zones.conf for the RedHat
  OS family

## 3.2.0
* Add empty_zones_enable and forward global parameters
* Add service_ensure, service_enable parameters to manage service properties
* Change allow_recursion default to localnets and localhost to prevent open
  recursion
* Support Puppet 3.0 minimum
* Support Fedora 21, remove Debian 6 (Squeeze), add Ubuntu 16.04

## 3.1.0
* Support configuration on FreeBSD
* Add namedconf_template/optionsconf_template parameters to override templates
* Add allow_recursion parameter to control it on a global level
* Add recursion, allow_query, dnssec_enable and dnssec_validation global
  parameters
* Add manage_file, forward and forwarders parameters to dns::zone
* Add also_notify parameter to dns::zone
* Change package resource to ensure_packages

## 3.0.0
* Change theforeman-concat_native to puppetlabs-concat
* Test with Puppet 4

## 2.0.1
* Fix template variable lookups under the future parser

## 2.0.0
* Add masters/allow_transfer parameters to dns::zone to configure master/slave
  relationships
* Require that dns is explicitly included, not implicitly included by dns::zone
* Add and refactor dns::zone parameters
* Improve dns::zone defaults for soa, soaip etc.
* Replace dns::zone parameters for zone path and filename
* Remove unused rndc_alg/secret parameters
* Improve style and fix linting issues
* Refresh README

## 1.4.0
* Add listen_on_v6 parameter
* Prevent create-rndc key exec changing on every run
* Puppet 2.6 support deprecated
* Update gitignore, change fixtures to HTTPS

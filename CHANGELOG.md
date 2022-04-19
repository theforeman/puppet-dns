# Changelog

## [9.3.0](https://github.com/theforeman/puppet-dns/tree/9.3.0) (2022-04-19)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/9.2.0...9.3.0)

**Implemented enhancements:**

- Handle dnssec-enable config option removal [\#210](https://github.com/theforeman/puppet-dns/pull/210) ([ekohl](https://github.com/ekohl))
- Add support for defining custom dnssec-policies [\#206](https://github.com/theforeman/puppet-dns/pull/206) ([smortex](https://github.com/smortex))
- Add support for `dnssec-policy` [\#205](https://github.com/theforeman/puppet-dns/pull/205) ([smortex](https://github.com/smortex))
- Update the specified bind version on FreeBSD to 9.16. [\#204](https://github.com/theforeman/puppet-dns/pull/204) ([rtprio](https://github.com/rtprio))

**Closed issues:**

- dnssec-enable no longer a valid configuration item. [\#207](https://github.com/theforeman/puppet-dns/issues/207)

## [9.2.0](https://github.com/theforeman/puppet-dns/tree/9.2.0) (2022-02-03)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/9.1.0...9.2.0)

**Implemented enhancements:**

- Support CentOS 9, Debian 11 and Ubuntu 20.04 [\#201](https://github.com/theforeman/puppet-dns/pull/201) ([ekohl](https://github.com/ekohl))
- puppetlabs/stdlib: Allow 8.x [\#199](https://github.com/theforeman/puppet-dns/pull/199) ([bastelfreak](https://github.com/bastelfreak))

## [9.1.0](https://github.com/theforeman/puppet-dns/tree/9.1.0) (2021-10-29)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/9.0.0...9.1.0)

**Implemented enhancements:**

- Move static parameters to init.pp [\#195](https://github.com/theforeman/puppet-dns/pull/195) ([ekohl](https://github.com/ekohl))

## [9.0.0](https://github.com/theforeman/puppet-dns/tree/9.0.0) (2021-07-22)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/8.2.0...9.0.0)

**Breaking changes:**

- Drop EL6 and Debian 8 and Ubuntu 16.04 support [\#193](https://github.com/theforeman/puppet-dns/pull/193) ([ehelms](https://github.com/ehelms))
- Drop Puppet 5 support [\#191](https://github.com/theforeman/puppet-dns/pull/191) ([ehelms](https://github.com/ehelms))

**Implemented enhancements:**

- Drop usage of -r from rndc-confgen [\#190](https://github.com/theforeman/puppet-dns/pull/190) ([karelyatin](https://github.com/karelyatin))
- Allow Puppet 7 compatible versions of mods [\#186](https://github.com/theforeman/puppet-dns/pull/186) ([ekohl](https://github.com/ekohl))
- Replace get\_in\_addr\_arpa with reverse\_dns function [\#175](https://github.com/theforeman/puppet-dns/pull/175) ([ekohl](https://github.com/ekohl))

**Closed issues:**

- create-rndc.key fails with bind9 9.13.0+ [\#189](https://github.com/theforeman/puppet-dns/issues/189)

## [8.2.0](https://github.com/theforeman/puppet-dns/tree/8.2.0) (2021-04-27)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/8.1.0...8.2.0)

**Implemented enhancements:**

- Support Puppet 7 [\#184](https://github.com/theforeman/puppet-dns/pull/184) ([ekohl](https://github.com/ekohl))
- Drop Fedora 26, add Fedora 32 [\#181](https://github.com/theforeman/puppet-dns/pull/181) ([ekohl](https://github.com/ekohl))
- Allow configuration checks to be turned off [\#178](https://github.com/theforeman/puppet-dns/pull/178) ([coreone](https://github.com/coreone))

## [8.1.0](https://github.com/theforeman/puppet-dns/tree/8.1.0) (2020-10-27)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/8.0.0...8.1.0)

**Implemented enhancements:**

- Add the ability to define logging [\#172](https://github.com/theforeman/puppet-dns/pull/172) ([coreone](https://github.com/coreone))

**Fixed bugs:**

- Enforce parameter\_documentation lint plugin [\#176](https://github.com/theforeman/puppet-dns/pull/176) ([ekohl](https://github.com/ekohl))
- Update zone documentation [\#174](https://github.com/theforeman/puppet-dns/pull/174) ([marcdeop](https://github.com/marcdeop))
- Fix custom key ordering [\#173](https://github.com/theforeman/puppet-dns/pull/173) ([coreone](https://github.com/coreone))

## [8.0.0](https://github.com/theforeman/puppet-dns/tree/8.0.0) (2020-05-13)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/7.0.0...8.0.0)

**Breaking changes:**

- Use modern facts [\#169](https://github.com/theforeman/puppet-dns/issues/169)
- Make bind view clauses optional [\#163](https://github.com/theforeman/puppet-dns/pull/163) ([dlucredativ](https://github.com/dlucredativ))
- Make zone update\_policy\_rules more generic [\#157](https://github.com/theforeman/puppet-dns/pull/157) ([damluk](https://github.com/damluk))

**Implemented enhancements:**

- Fixes [\#29210](https://projects.theforeman.org/issues/29210) - support el8 [\#160](https://github.com/theforeman/puppet-dns/pull/160) ([wbclark](https://github.com/wbclark))
- Introduce several dnssec related zone options [\#158](https://github.com/theforeman/puppet-dns/pull/158) ([damluk](https://github.com/damluk))

## [7.0.0](https://github.com/theforeman/puppet-dns/tree/7.0.0) (2020-02-11)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/6.2.0...7.0.0)

**Breaking changes:**

- Refactor soaip in dns::zone [\#151](https://github.com/theforeman/puppet-dns/pull/151) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- Add Debian 10 [\#153](https://github.com/theforeman/puppet-dns/pull/153) ([mmoll](https://github.com/mmoll))
- Add manage\_service parameter [\#149](https://github.com/theforeman/puppet-dns/pull/149) ([flyingstar16](https://github.com/flyingstar16))

## [6.2.0](https://github.com/theforeman/puppet-dns/tree/6.2.0) (2019-07-19)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/6.1.0...6.2.0)

**Implemented enhancements:**

- Validate named.conf and zones.conf using named-checkconf [\#144](https://github.com/theforeman/puppet-dns/pull/144) ([antaflos](https://github.com/antaflos))
- Allow setting service restart command [\#143](https://github.com/theforeman/puppet-dns/pull/143) ([antaflos](https://github.com/antaflos))
- Don't set forbidden zone options for zone type 'forward' [\#142](https://github.com/theforeman/puppet-dns/pull/142) ([antaflos](https://github.com/antaflos))

## [6.1.0](https://github.com/theforeman/puppet-dns/tree/6.1.0) (2019-06-12)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/6.0.0...6.1.0)

**Implemented enhancements:**

- Add support for managing sysconfig settings [\#145](https://github.com/theforeman/puppet-dns/pull/145) ([antaflos](https://github.com/antaflos))
- Make managing BIND system group optional [\#139](https://github.com/theforeman/puppet-dns/pull/139) ([antaflos](https://github.com/antaflos))

**Merged pull requests:**

- Allow puppetlabs/concat and puppetlabs/stdlib 6.x [\#146](https://github.com/theforeman/puppet-dns/pull/146) ([alexjfisher](https://github.com/alexjfisher))

## [6.0.0](https://github.com/theforeman/puppet-dns/tree/6.0.0) (2019-04-15)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/5.4.0...6.0.0)

**Breaking changes:**

- drop Puppet 4 [\#137](https://github.com/theforeman/puppet-dns/pull/137) ([mmoll](https://github.com/mmoll))
- drop EOL OSes [\#136](https://github.com/theforeman/puppet-dns/pull/136) ([mmoll](https://github.com/mmoll))

## [5.4.0](https://github.com/theforeman/puppet-dns/tree/5.4.0) (2019-01-10)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/5.3.1...5.4.0)

**Implemented enhancements:**

- Convert documentation to puppet-strings [\#133](https://github.com/theforeman/puppet-dns/pull/133) ([ekohl](https://github.com/ekohl))
- Add keys parameter and create\_resources accordingly [\#130](https://github.com/theforeman/puppet-dns/pull/130) ([marcdeop](https://github.com/marcdeop))
- Add Puppet 6 support [\#129](https://github.com/theforeman/puppet-dns/pull/129) ([ekohl](https://github.com/ekohl))

## [5.3.1](https://github.com/theforeman/puppet-dns/tree/5.3.1) (2018-10-04)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/5.3.0...5.3.1)

**Merged pull requests:**

- Allow puppetlabs/stdlib 5.x [\#126](https://github.com/theforeman/puppet-dns/pull/126) ([ekohl](https://github.com/ekohl))
- allow puppetlabs-concat 5.x [\#122](https://github.com/theforeman/puppet-dns/pull/122) ([mmoll](https://github.com/mmoll))

## [5.3.0](https://github.com/theforeman/puppet-dns/tree/5.3.0) (2018-07-16)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/5.2.0...5.3.0)

**Implemented enhancements:**

- Support Ubuntu/bionic, drop Fedora 25 [\#115](https://github.com/theforeman/puppet-dns/pull/115) ([mmoll](https://github.com/mmoll))

## [5.2.0](https://github.com/theforeman/puppet-dns/tree/5.2.0) (2018-05-22)

[Full Changelog](https://github.com/theforeman/puppet-dns/compare/5.1.0...5.2.0)

**Implemented enhancements:**

- Adds control keys and specifying update policy [\#108](https://github.com/theforeman/puppet-dns/pull/108) ([zyronix](https://github.com/zyronix))

**Closed issues:**

- Fails with puppetlabs/concat 4.1.1 [\#107](https://github.com/theforeman/puppet-dns/issues/107)
- Add support for adding keys for nsupdate [\#94](https://github.com/theforeman/puppet-dns/issues/94)

## 5.1.0

* Stop shipping development code in releases
* Remove EOL operating systems and add new ones

## 5.0.1

* Add a zones parameter
* Disallow undef values for `$localzonepath` and `$defaultzonepath` in favor of `'unmanaged'` (default parameter)

## 5.0.0

* Drop Puppet 3 support
* Add BIND views support

## 4.1.0

* Add `$allow_query` parameter for zones.
* Add `$additional_directives` parameter to define top-scope directives in
  `named.conf`.
* Document all class parameters.

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


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*

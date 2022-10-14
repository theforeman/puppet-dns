[![Puppet Forge](https://img.shields.io/puppetforge/v/theforeman/dns.svg)](https://forge.puppetlabs.com/theforeman/dns)
[![Build Status](https://travis-ci.org/theforeman/puppet-dns.svg?branch=master)](https://travis-ci.org/theforeman/puppet-dns)

# DNS module for Puppet

Installs and manages an ISC BIND DNS server with basic zones, primarily for The
Foreman.

# Usage

Include the top level `dns` class to fully configure the service.

```puppet
include dns
```

A key is set up to allow dynamic DNS updates, stored in rndc.key.  This is used
by Foreman's smart proxy to add and remove records on the fly.

Zones can be created with the `dns::zone` resource:

```puppet
dns::zone { 'example.com': }
```

Keys can be created with the `dns::key` resource:

```puppet
dns::key {'dns-key':}
```

Slaves can also be configured by setting `allow_transfer` in the master's zone
and setting `zonetype => 'slave'` in the slave's zone.

Logging can be added with the `dns::logging_categories` and `dns::logging_channels` defined types.  The following Hiera example shows all the available options:

```yaml
dns::logging_categories:
  unmatched:
    channels:
      - 'test_file'
      - 'test_stderr'
      - 'test_syslog'
      - 'test_null'
dns::logging_channels:
  test_file:
    file_path: '/var/log/named/test.log'
    file_versions: 3
    file_size: '5m'
    log_type: 'file'
    print_category: 'yes'
    print_severity: 'yes'
    print_time: 'yes'
    severity: 'dynamic'
  test_null:
    log_type: 'null'
    print_category: 'yes'
    print_severity: 'yes'
    print_time: 'yes'
    severity: 'dynamic'
  test_stderr:
    log_type: 'stderr'
    print_category: 'yes'
    print_severity: 'yes'
    print_time: 'yes'
    severity: 'dynamic'
  test_syslog:
    log_type: 'syslog'
    print_category: 'yes'
    print_severity: 'yes'
    print_time: 'yes'
    severity: 'dynamic'
    syslog_facility: 'auth'
```

## isc-bind Software Collections usage
If you plan to use the isc-bind SCL packages (https://copr.fedorainfracloud.org/coprs/isc/bind/) the string 'dns::globals::scl'
must be set, which also directly identifies the scl environment that is used.

This can be accomplished by using hiera
```yaml
dns::globals::scl: 'isc-bind'
``

or class instantiation.
```puppet
class { 'dns::globals':
  scl => 'isc-bind'
}
```

# Credits

Based on zleslie-dns, with a lot of the guts ripped out. Thanks
to zleslie for the original work

# Contributing

* Fork the project
* Commit and push until you are happy with your contribution
* Send a pull request with a description of your changes

See the CONTRIBUTING.md file for much more information.

# More info

See [https://theforeman.org](https://theforeman.org) or at #theforeman irc channel on freenode

Copyright (c) 2010-2016 Foreman developers and Zach Leslie

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[https://www.apache.org/licenses/LICENSE-2.0](https://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

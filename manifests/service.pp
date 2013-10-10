class dns::service {
  service { $dns::namedservicename:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}

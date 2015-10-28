# Enable and start dns service
class dns::service {
  service { $dns::namedservicename:
    ensure     => $dns::service_ensure,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}

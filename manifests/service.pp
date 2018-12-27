# Enable and start dns service
# @api private
class dns::service {
  service { $dns::namedservicename:
    ensure     => $dns::service_ensure,
    enable     => $dns::service_enable,
    hasstatus  => true,
    hasrestart => true,
  }
}

# Install dns service
# @api private
class dns::install {
  if ! empty($dns::dns_server_package) {
    ensure_packages([$dns::dns_server_package])
    $pkg_req = Package[$dns::dns_server_package]
  } else {
    $pkg_req = undef
  }

  if $dns::group_manage {
    group { $dns::group:
      require => $pkg_req,
    }
  }
}

# Install dns service
# @api private
class dns::install {
  if ! empty($dns::dns_server_package) {
    ensure_packages([$dns::dns_server_package])
  }
}

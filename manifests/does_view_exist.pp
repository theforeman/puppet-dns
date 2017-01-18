# internal check for view existence when referred to in a dns::zone
# this should be reimplemented with lambdas as soon as puppet-dns drops
# support for older puppet versions.
define dns::does_view_exist($view) {  Dns::View[$view] -> Class['::dns'] }

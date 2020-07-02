# Define new category for logging
#
# @param channels
#   The array of channels to attach to the category
#
# @param order
#   The order of the category in the configuration file
define dns::logging::category (
  Array $channels,
  Integer[51, 59] $order = 55,
) {
  include dns::logging

  $category_name = $title

  concat::fragment { "named.conf-logging-category-${title}.dns":
    target  => $dns::namedconf_path,
    content => template('dns/log.category.conf.erb'),
    order   => $order,
  }
}
